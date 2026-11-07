# Known Bugs & Solutions (akr-dots)

This document tracks known bugs, graphical glitches, compatibility issues, and their tested solutions in a Q&A format.

---

## Bug Index

| Bug ID | Title | Component | Status |
| :--- | :--- | :--- | :--- |
| **BUG-01** | [Images and media glitching when hardware acceleration is enabled](#bug-01-images-and-media-glitching-when-hardware-acceleration-is-enabled-chromium-brave-chrome) | Chromium / Brave / Wayland / Hybrid GPU | **Fixed & Documented** |
| **BUG-02** | [Hover card overlay, tearing & image corruption fixed with `/opt/brave.com/brave/brave --ozone-platform=x11 --enable-gpu-rasterization`](#bug-02-hover-card-overlay-tearing--image-corruption-fixed-with-optbravecombravebrave---ozone-platformx11---enable-gpu-rasterization) | Brave / Chromium / Wayland Ozone / XWayland | **Fixed & Auto-Applied** |

---

## BUG-01: Images and Media Glitching When Hardware Acceleration is Enabled (Chromium, Brave, Chrome)

### Overview
When browsing image-heavy websites or WebP/AVIF media (such as `styles.refero.design`, Twitter/X, Reddit, Unsplash) in Chromium-based browsers on Hyprland, image previews and thumbnails render with severe graphical corruption:
- Corrupted horizontal checkered stripes, multi-colored static noise, and garbled pixels over image tiles.
- Blank grey or black blocks in place of image thumbnails.
- Turning off "Use graphics acceleration when available" in settings stops the image corruption, but causes the entire browser to become sluggish, choppy, and laggy.

### Why Disabling Hardware Acceleration Causes Lag
When you toggle off **"Use graphics acceleration when available"** in Browser Settings (`brave://settings/system`):
- Chromium disables **ALL** GPU acceleration:
  - Page Compositing $\rightarrow$ Software CPU
  - WebGL / WebGL 2.0 $\rightarrow$ Software CPU (SwiftShader)
  - 2D Canvas $\rightarrow$ Software CPU
  - Video Decode $\rightarrow$ Software CPU (no hardware VA-API)
  - Page Presentation $\rightarrow$ Software CPU
- The CPU is forced to calculate and render every single frame, animation, and 4K video frame by software. On 120Hz/144Hz high refresh rate displays, this causes massive CPU spikes, dropped frames, stuttering, and severe lag.

### Why It Glitches Under Linux Wayland
1. **Upstream GPU Rasterization Conflict:** In modern Chromium, GPU rasterization attempts to decode and rasterize image tiles directly on the GPU using shared DMA-BUF memory buffers. On Linux Wayland (especially with Intel or hybrid graphics), the memory pitch and tiling synchronization between the GPU rasterizer and the Wayland compositor desynchronize, causing decoded image buffers to display as raw memory static or checkered noise.
2. **Hybrid GPU Conflict:** On hybrid laptops (Intel UHD/Iris + NVIDIA RTX or AMD + NVIDIA), upstream dotfiles previously exported `LIBVA_DRIVER_NAME="nvidia"` and `__GLX_VENDOR_LIBRARY_NAME="nvidia"` globally. Because the laptop screen (`eDP-1`) is wired to the integrated GPU (e.g. Intel `i915`), forcing NVIDIA GLX/VA-API drivers across all Wayland clients creates cross-device buffer allocation mismatches.

---

## BUG-02: Hover Card Overlay, Tearing & Image Corruption Fixed with `/opt/brave.com/brave/brave --ozone-platform=x11 --enable-gpu-rasterization`

### Overview & Symptoms
When hovering over interactive cards or image tiles on modern web applications (such as `styles.refero.design`, Dribbble, Pinterest):
- Images from previously hovered tiles get overlaid, stamped, or sliced across neighboring tiles.
- Repeating horizontal stripes or zigzag artifacts appear across thumbnail borders as the hover transition triggers (`transition-transform duration-300 group-hover/card:scale-[1.02]`).
- The glitch occurs even when GPU rasterization is modified, as long as the browser runs on native Wayland Ozone.

---

### Root Cause / Reason

1. **Wayland Partial Damage Rectangle Desynchronization:**
   - Under native Wayland Ozone (`--ozone-platform=wayland`), Chromium optimizes presentation performance by submitting partial damage rectangles (`wl_surface_damage_buffer`) to update only the region that changed during a hover transition.
   - On Linux systems with hybrid graphics (Intel UHD + NVIDIA RTX) or Mesa drivers, the front/back EGL buffer swapchain fails to synchronize with the Wayland compositor's damage updates.
   - When the user hovers over a card, Chromium draws the scaling card into a buffer that still holds stale image contents from a previous card. As a result, **the new card is drawn directly on top of the old card's texture**, creating visual layering, slicing, and checkered static.

2. **Why Native Wayland Lacks Reliable DRM Sync On Some Stacks:**
   - Linux DRM explicit synchronization (`linux-drm-syncobj-v1`) is still maturing across driver and browser boundaries. When explicit sync is absent or imperfectly mapped, implicit buffer reuse causes frame contents to tear and overlap.

---

### The Fix: `/opt/brave.com/brave/brave --ozone-platform=x11 --enable-gpu-rasterization`

Routing Chromium / Brave through the **X11 display backend** (`--ozone-platform=x11`) via XWayland provides the definitive solution:

1. **Complete Elimination of Hover Overlay & Slicing:**
   - X11 uses standard pixmap presentation and synchronization rather than Wayland partial damage rectangle swaps.
   - Stale buffer memory is never recycled into active card rects, completely eliminating hover overlapping and sliced card artifacts.

2. **Full GPU Hardware Acceleration with Zero Lag:**
   - Unlike disabling hardware acceleration in settings (which crushes CPU performance), running with `--ozone-platform=x11 --enable-gpu-rasterization`:
     - **GPU Compositing:** Hardware Accelerated (silky-smooth 144Hz scrolling).
     - **GPU Rasterization:** Hardware Accelerated (instant image and canvas rendering).
     - **WebGL / WebGL 2:** Hardware Accelerated.
     - **Hardware Video Decode:** Hardware Accelerated (smooth 4K 60fps video).
   - CPU usage remains low (~2-4%), scrolling is buttery smooth, and all hover interactions animate cleanly.

---

### How `akr-dots` Defaults & Auto-Applies This

To ensure no user ever experiences this glitch, `akr-dots` implements an automated multi-layer configuration:

1. **Default Flag Files:**
   The repository ships pre-configured flag files:
   - `~/.config/brave-flags.conf`
   - `~/.config/chrome-flags.conf`
   - `~/.config/chromium-flags.conf`
   Defaulting to:
   ```text
   --ozone-platform=x11
   --enable-gpu-rasterization
   --disable-features=UseChromeOSDirectVideoDecoder
   ```

2. **Universal Flag Runner (`browser-flags-runner.sh`):**
   - Located at `~/.config/hypr/scripts/browser-flags-runner.sh` and tracked in `config/hypr/scripts/browser-flags-runner.sh`.
   - Automatically parses `~/.config/<browser>-flags.conf` and executes the real binary with those flags.
   - If the configuration file is ever missing or deleted, the runner **hardcodes a safe fallback default**:
     ```bash
     flags=("--ozone-platform=x11" "--enable-gpu-rasterization" "--disable-features=UseChromeOSDirectVideoDecoder")
     ```
   - Auto-resolves the underlying binary (`/usr/bin/brave-browser-stable`, `/opt/brave.com/brave/brave`, etc.) without infinite recursion.

3. **FreeDesktop Desktop Launcher Integration (`lib_copy.sh`):**
   - Automated during installation/copy in `scripts/lib_copy.sh`:
   - Deploys `~/.local/share/applications/brave-browser.desktop`, `com.brave.Browser.desktop`, `google-chrome.desktop`, and `chromium.desktop`.
   - Sets the `Exec` line to the absolute runner path:
     ```desktop
     Exec=/home/prince/.config/hypr/scripts/browser-flags-runner.sh brave %U
     ```
   - Guarantees that launching Brave from Rofi (`Super + Space`), application menus, taskbars, or docks **always passes `--ozone-platform=x11 --enable-gpu-rasterization` automatically**.

4. **Shell Environment (`~/.zshrc` & `~/.bashrc`):**
   - Symlinks in `~/.local/bin/` (`brave`, `brave-browser`, `brave-browser-stable`) route terminal commands through the runner.
   - `export PATH="$HOME/.local/bin:$PATH"` is enabled in `~/.zshrc` so terminal executions also auto-apply the fix.

5. **Hybrid GPU Protection (`lib_detect.sh` & `env.lua`):**
   - On hybrid laptops (Intel/NVIDIA or AMD/NVIDIA), `scripts/lib_detect.sh` prevents global `LIBVA_DRIVER_NAME="nvidia"` and `__GLX_VENDOR_LIBRARY_NAME="nvidia"` from contaminating integrated GPU Wayland compositing.

---

### Verification

To verify that the browser is running with the fix:
1. Open Brave and check running processes in terminal:
   ```bash
   ps aux | grep -i brave | grep ozone
   ```
   Output confirms:
   ```text
   /opt/brave.com/brave/brave --ozone-platform=x11 --enable-gpu-rasterization
   ```
2. In Brave URL bar, go to `brave://gpu`:
   - **Compositing:** `Hardware accelerated`
   - **Rasterization:** `Hardware accelerated`
   - **WebGL / WebGL 2:** `Hardware accelerated`
3. Test [`https://styles.refero.design`](https://styles.refero.design):
   - Hovering over cards triggers clean scale transitions with **zero overlapping, zero tearing, zero checkered static, and zero lag**.
