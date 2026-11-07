# Known Bugs & Solutions (akr-dots)

This document tracks known bugs, graphical glitches, compatibility issues, and their tested solutions in a Q&A format.

---

## Bug Index

| Bug ID | Title | Component | Status |
| :--- | :--- | :--- | :--- |
| **BUG-01** | [Images and media glitching in Chromium-based browsers](#bug-01-images-and-media-glitching-in-chromium-based-browsers-brave-chrome-chromium-edge) | Chromium / Brave / Wayland / GPU | **Fixed / Documented** |

---

## BUG-01: Images and Media Glitching in Chromium-Based Browsers (Brave, Chrome, Chromium, Edge)

### Overview
When browsing websites with dynamic images, WebP/AVIF media, or canvas elements (e.g., `styles.refero.design`, Twitter/X, Reddit, Unsplash) in Chromium-based browsers on Hyprland, image previews and thumbnails render with severe graphical corruption:
- Black boxes with horizontal static noise and corrupted scanlines.
- Blank white or partially clipped preview cards.
- Flickering or checkered rendering artifacts during scrolling.

---

### Questions & Answers (Q&A)

#### Q1: What causes this image glitching?
**A:** This is caused by a buffer synchronization mismatch between Chromium's **Ozone Wayland platform**, the **ANGLE graphics abstraction layer**, and Linux GPU drivers (especially NVIDIA and Intel/NVIDIA hybrid graphics setups).

By default, Chromium uses ANGLE with the EGL backend on Wayland. Under modern Wayland compositors like Hyprland, texture memory and DMA-BUF surfaces for 2D canvas rasterization and decoded images fail to synchronize properly between the Chromium GPU process and the compositor, producing corrupted or uninitialized GPU texture memory on screen.

---

#### Q2: What is the recommended fix inside the browser (GUI)?
**A:** You can resolve this directly within your browser settings in less than a minute:

1. **Change the ANGLE Graphics Backend (Most effective):**
   - Open your browser and navigate to the internal flags page:
     - Brave: `brave://flags`
     - Chrome: `chrome://flags`
     - Chromium / Edge: `chrome://flags` or `edge://flags`
   - In the search box, search for **"Choose ANGLE graphics backend"** (flag `#use-angle`).
   - Change the dropdown from **Default** to **OpenGL** (or **Vulkan** if supported by your drivers).
   - Click the **Relaunch** button at the bottom of the page.

2. **Disable GPU Rasterization (Alternative if glitching persists):**
   - Search for **"GPU rasterization"** in `chrome://flags` (flag `#enable-gpu-rasterization`).
   - Set it to **Disabled**.
   - Relaunch the browser.

3. **Disable Hardware Acceleration (Failsafe guarantee):**
   - Go to your browser Settings $\rightarrow$ **System** (or `brave://settings/system`).
   - Toggle off **"Use graphics acceleration when available"**.
   - Relaunch the browser. This completely offloads image rendering and video decoding to the CPU, guaranteeing zero artifacts.

---

#### Q3: How do I fix this permanently across all launches via configuration files?
**A:** Chromium-based browsers on Linux support flag configuration files in your home config directory. `akr-dots` ships templates for these files:

- **Brave:** `~/.config/brave-flags.conf`
- **Google Chrome:** `~/.config/chrome-flags.conf`
- **Chromium:** `~/.config/chromium-flags.conf`
- **Electron apps:** `~/.config/electron-flags.conf`

Add the following flags to your browser's flag file:
```text
--ozone-platform-hint=auto
--enable-features=WaylandWindowDecorations
--use-angle=gl
--disable-features=UseChromeOSDirectVideoDecoder
```

*(Note: If you are running an NVIDIA proprietary driver and prefer Vulkan over OpenGL, replace `--use-angle=gl` with `--use-angle=vulkan`)*.

---

#### Q4: How can I launch the browser from terminal or shortcuts with the fix?
**A:** Pass the `--use-angle=gl` flag directly when launching:

```bash
# For Brave:
brave-browser --use-angle=gl

# For Google Chrome:
google-chrome-stable --use-angle=gl

# For Chromium:
chromium --use-angle=gl
```

To run through XWayland as an emergency fallback:
```bash
brave-browser --ozone-platform=x11
```

---

#### Q5: What built-in fixes are included in `akr-dots`?
**A:** `akr-dots` provides the following out-of-the-box safeguards:
1. **Shipped Flag Configs:** `config/brave-flags.conf`, `config/chrome-flags.conf`, and `config/chromium-flags.conf` are maintained in the repository and automatically deployed to `~/.config/` via `copy.sh`.
2. **Environment Configuration:** Hyprland exports `ELECTRON_OZONE_PLATFORM_HINT="auto"` and cursor fix `no_hardware_cursors = 1` for hybrid/NVIDIA setups in `config/hypr/lua/settings.lua` and `config/hypr/lua/env.lua` to prevent cursor and compositor synchronization stalls.

