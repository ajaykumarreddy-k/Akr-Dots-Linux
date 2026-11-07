# Known Bugs & Solutions (akr-dots)

This document tracks known bugs, graphical glitches, compatibility issues, and their tested solutions in a Q&A format.

---

## Bug Index

| Bug ID | Title | Component | Status |
| :--- | :--- | :--- | :--- |
| **BUG-01** | [Images and media glitching in Chromium-based browsers](#bug-01-images-and-media-glitching-in-chromium-based-browsers-brave-chrome-chromium-edge) | Chromium / Brave / Wayland / Hybrid GPU | **Fixed & Documented** |

---

## BUG-01: Images and Media Glitching in Chromium-Based Browsers (Brave, Chrome, Chromium, Edge)

### Overview
When browsing websites with dynamic images, WebP/AVIF media, or canvas elements (e.g., `styles.refero.design`, Twitter/X, Reddit, Unsplash) in Chromium-based browsers on Hyprland, image previews and thumbnails render with severe graphical corruption:
- Corrupted horizontal checkered stripes, multi-colored static noise, and garbled pixels over image tiles.
- Hovering over cards causes previous tile images to get overlaid or sliced across neighboring tiles (due to Wayland partial damage rectangle buffer desync).
- Blank grey or black blocks in place of image thumbnails.
- Turning off "Use graphics acceleration when available" stops the glitch, but makes the browser sluggish, slow, and laggy.

---

### Questions & Answers (Q&A)

#### Q1: Is this a Chromium issue or a dotfiles issue?
**A:** It is a combination of both:
1. **Upstream Chromium Wayland Damage & Hover Bug:** When hovering over interactive cards (e.g. elements with `transition: transform` or `scale(1.02)`), Chromium's native Wayland Ozone backend sends partial damage rectangles (`wl_surface_damage_buffer`) while swapping buffers. On hybrid graphics and Mesa drivers, the front/back buffer swap desynchronizes, causing stale image memory from previous hover frames to be stamped over the active card.
2. **GPU Rasterization & Skia Graphite Corruption:** In modern Chromium, GPU rasterization attempts to decode images into shared DMA-BUF memory buffers. On Linux Wayland with hybrid GPUs, pitch and tiling desynchronize, rendering raw memory static.
3. **Hybrid GPU Environment Conflict:** On hybrid laptops (Intel UHD/Iris + NVIDIA RTX or AMD + NVIDIA), upstream dotfiles previously exported `LIBVA_DRIVER_NAME="nvidia"` and `__GLX_VENDOR_LIBRARY_NAME="nvidia"` globally. Because the laptop screen (`eDP-1`) is wired to the integrated GPU (e.g. Intel `i915`), forcing NVIDIA GLX/VA-API drivers across all Wayland clients creates cross-device buffer allocation mismatches, exacerbating texture corruption.
4. **Packaging Difference (Debian/Ubuntu vs Arch):** Arch Linux's browser packages natively read `~/.config/brave-flags.conf`. However, on Debian and Ubuntu, upstream packages (`/usr/bin/brave-browser-stable`) launch `/opt/brave.com/brave/brave` directly without reading `*-flags.conf`, so flag adjustments were never applied unless specifically routed through an absolute launcher runner.

---

#### Q2: Why does turning off Hardware Acceleration make the browser slow and laggy?
**A:** When you toggle off **"Use graphics acceleration when available"** in Browser Settings (`brave://settings/system`):
- Chromium disables **ALL** GPU acceleration:
  - Page Compositing $\rightarrow$ Software CPU
  - WebGL / WebGL 2.0 $\rightarrow$ Software CPU (SwiftShader)
  - 2D Canvas $\rightarrow$ Software CPU
  - Video Decode $\rightarrow$ Software CPU (no hardware VA-API)
  - Page Presentation $\rightarrow$ Software CPU
- The CPU is forced to calculate and render every single frame, animation, and 4K video frame by software. On 120Hz/144Hz high refresh rate displays, this causes massive CPU spikes, dropped frames, stuttering, and severe lag.

---

#### Q3: How do we fix BOTH the checkered images AND hover overlay glitches while keeping 100% fast GPU acceleration?
**A:** The definitive, tested fix is setting the display backend to **X11 / XWayland** (`--ozone-platform=x11`):
1. **Why `--ozone-platform=x11` fixes it:**
   - On XWayland, Chromium uses standard X11 pixmap presentation and synchronization instead of broken Wayland partial damage rectangles.
   - Images **never slice or overlay on hover**.
   - Decoded textures **never corrupt into checkered static**.
   - **Hardware acceleration remains 100% active on the GPU** (GPU Compositing: Hardware Accelerated, WebGL: Hardware Accelerated, Video Decode: Hardware Accelerated) running at full monitor refresh rate (144Hz) with zero lag.
2. **Alternative GUI Setting (in `brave://flags`):**
   - In Brave's address bar, go to `brave://flags`.
   - Search for **"Preferred Ozone platform"** (`#ozone-platform-hint`).
   - Change from *Default* or *Auto* to **X11**.
   - Click **Relaunch**. This bakes the fix directly into Brave's profile.

---

#### Q4: How is this solved permanently in `akr-dots`?
**A:** `akr-dots` implements a multi-layer solution:

1. **Configured Flag Files:**
   The repository ships optimized flag files:
   - `~/.config/brave-flags.conf`
   - `~/.config/chrome-flags.conf`
   - `~/.config/chromium-flags.conf`
   Containing:
   ```text
   --ozone-platform=x11
   --enable-gpu-rasterization
   --disable-features=UseChromeOSDirectVideoDecoder
   ```

2. **Universal Flag Runner (`browser-flags-runner.sh`):**
   Located at `~/.config/hypr/scripts/browser-flags-runner.sh`, this wrapper dynamically parses the corresponding `*-flags.conf` file, strips comments, and passes the flags to the underlying browser binary. Symlinks are installed in `~/.local/bin/` (`brave`, `brave-browser`, `brave-browser-stable`, `google-chrome`, `chromium`).

3. **Desktop Launcher Overrides:**
   FreeDesktop `.desktop` entries in `~/.local/share/applications/` (`brave-browser.desktop`, `com.brave.Browser.desktop`) explicitly invoke `/home/prince/.config/hypr/scripts/browser-flags-runner.sh brave %U` so that clicking the browser in Rofi, application menus, or taskbars automatically passes the flags.

4. **Shell Environment (`~/.zshrc` & `~/.bashrc`):**
   Ensured `export PATH="$HOME/.local/bin:$PATH"` is loaded so that terminal launches also invoke the runner.

5. **Hybrid GPU Protection in `lib_detect.sh`:**
   Hardware detection in `scripts/lib_detect.sh` and `config/hypr/lua/env.lua` now distinguishes between pure dedicated NVIDIA desktops and hybrid laptops (Intel/NVIDIA or AMD/NVIDIA). On hybrid laptops, `LIBVA_DRIVER_NAME="nvidia"` and `__GLX_VENDOR_LIBRARY_NAME="nvidia"` are kept disabled so that iGPU Wayland compositing and DMA-BUF zero-copy presentation remain stable.

2. **Universal Flag Runner (`browser-flags-runner.sh`):**
   Located at `~/.config/hypr/scripts/browser-flags-runner.sh`, this wrapper dynamically parses the corresponding `*-flags.conf` file, strips comments, and passes the flags to the underlying browser binary. Symlinks are installed in `~/.local/bin/` (`brave`, `brave-browser`, `brave-browser-stable`, `google-chrome`, `chromium`).

3. **Desktop Launcher Overrides:**
   FreeDesktop `.desktop` entries in `~/.local/share/applications/` (`brave-browser.desktop`, `com.brave.Browser.desktop`) ensure that clicking the browser in Rofi, application menus, or taskbars automatically passes the flags.

4. **Hybrid GPU Protection in `lib_detect.sh`:**
   Hardware detection in `scripts/lib_detect.sh` and `config/hypr/lua/env.lua` now distinguishes between pure dedicated NVIDIA desktops and hybrid laptops (Intel/NVIDIA or AMD/NVIDIA). On hybrid laptops, `LIBVA_DRIVER_NAME="nvidia"` and `__GLX_VENDOR_LIBRARY_NAME="nvidia"` are kept disabled so that iGPU Wayland compositing and DMA-BUF zero-copy presentation remain stable.

---

#### Q5: How can I verify the fix is active in Brave / Chrome?
**A:**
1. Open your browser and navigate to:
   - `brave://gpu` or `chrome://gpu`
2. Under **Graphics Feature Status**, verify:
   - **Compositing:** `Hardware accelerated`
   - **WebGL / WebGL 2:** `Hardware accelerated`
   - **Video Decode:** `Hardware accelerated`
   - **Rasterization:** `Software only` (this confirms the glitch fix is active)
3. Navigate to `https://styles.refero.design` or any image-heavy website:
   - Images, cards, and previews load instantly with crisp, clean visuals and zero checkered noise.
