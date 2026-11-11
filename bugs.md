# Known Bugs & Solutions (akr-dots)

This document tracks known bugs, graphical glitches, compatibility issues, and their tested solutions in a Q&A format.

---

## Bug Index

| Bug ID | Title | Component | Status |
| :--- | :--- | :--- | :--- |
| **BUG-01** | [Images and media glitching when hardware acceleration is enabled](#bug-01-images-and-media-glitching-when-hardware-acceleration-is-enabled-chromium-brave-chrome) | Chromium / Brave / Wayland / Hybrid GPU | **Fixed & Documented** |
| **BUG-02** | [Hover card overlay, tearing & image corruption fixed with `/opt/brave.com/brave/brave --ozone-platform=x11 --enable-gpu-rasterization`](#bug-02-hover-card-overlay-tearing--image-corruption-fixed-with-optbravecombravebrave---ozone-platformx11---enable-gpu-rasterization) | Brave / Chromium / Wayland Ozone / XWayland | **Fixed & Auto-Applied** |
| **BUG-03** | [Scrolling layout over-zooming & tape width default (SUPER + ALT + 3)](#bug-03-scrolling-layout-over-zooming--tape-width-default-super--alt--3) | Hyprland Scrolling / ChangeLayout / PersistWorkspaceLayout | **Fixed & Auto-Applied** |
| **BUG-04** | [VLC video pinned to top-left corner with black right/bottom margins on Wayland](#bug-04-vlc-video-pinned-to-top-left-corner-with-black-rightbottom-margins-on-wayland) | VLC / Qt5 Wayland / D-Bus / XWayland | **Fixed & Auto-Applied** |

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

---

## BUG-03: Scrolling Layout Over-Zooming & Tape Width Default (`SUPER` + `ALT` + `3`)

### Overview & Symptoms
When activating the **Scrolling layout** (via keyboard shortcut **`SUPER` + `ALT` + `3`** or the Rofi layout switcher menu):
- Windows would blow up to 100% full screen width (`1906px`), mimicking an unwanted monocle mode.
- Users could not see an adjacent window peeking on the scrolling tape, making the workspace feel like it was "over-zoomed" or stuck.
- When cycling or switching layouts, Hyprland returned errors like `Unknown dwindle layoutmsg: colresize` because layout dispatchers were mismatched against the active workspace layout.
- Additionally, switching layout rules on workspace 1 was not being saved permanently to `workspaces.lua`.

---

### Root Causes
1. **Single-Column Fullscreen Mode Enabled (`fullscreen_on_one_column = true`)**:
   - In `settings.lua`, `fullscreen_on_one_column` was set to `true`.
   - In Hyprland's scrolling layout, whenever a workspace contains only one column (or during initial window creation), it automatically maximizes the window across 100% of the display, causing aggressive over-zooming.
2. **Suboptimal Column Width**:
   - The default column width did not provide the ideal 85% width (`0.85`) with a 15% side-peek for neighboring columns on the tape.
3. **Comment Regex False-Positive in `PersistWorkspaceLayout.sh`**:
   - The persistence script's regex `r'hl\.workspace_rule\(\s*\{([^}]+)\}\s*\)'` matched the commented-out template header `-- hl.workspace_rule({ workspace = "1", ... })` in `UserConfigs/workspaces.lua`.
   - The script thought workspace 1 was already present, set `updated = True`, and skipped writing the real workspace 1 rule.
4. **Dispatcher Layout Mismatch**:
   - `ChangeLayout.sh` registered workspace rules without updating Hyprland's `general:layout`, causing layout message commands (`colresize`, `layoutmsg focus r`) to route to Dwindle instead of Scrolling.

---

### The Fix: Balanced `0.85` Column Width & Clean Tape Navigation

1. **Configured `column_width = 0.85` with Side Tape Peek**:
   - In `config/hypr/lua/settings.lua`:
     ```lua
     hl.config({
       scrolling = {
         column_width = 0.85,
         fullscreen_on_one_column = false,
         direction = "right",
         follow_focus = true,
       },
     })
     ```
   - Active windows occupy **85%** of the display (`1612px` on 1080p) aligned cleanly to the side, leaving **15%** for the adjacent column peeking on the screen edge.
   - Disabled single-column fullscreen blowup (`fullscreen_on_one_column = false`).

2. **Added `0.85` to Window Action Presets (`window_actions.lua`)**:
   - Updated `COLUMN_WIDTH_PRESETS` to `{ 0.25, 0.33, 0.5, 0.66, 0.75, 0.85, 1.0 }`.
   - Pressing **`SUPER` + `R`** allows cycling column widths dynamically through all presets including 85%.

3. **Synchronized Layout Engine (`ChangeLayout.sh`)**:
   - `ChangeLayout.sh` updates both the per-workspace rule and `general:layout = target`, ensuring dispatchers handle column navigation (`focus r/l`, `move +col/-col`) without errors.
   - Automatically executes `colresize 0.85` when switching to scrolling layout.

4. **Regex Fix in `PersistWorkspaceLayout.sh`**:
   - Updated the rule parser to ignore commented lines (`(?m)^(?![ \t]*--)[ \t]*hl\.workspace_rule`), ensuring layout choices for workspace 1 (and all workspaces) persist correctly across reboots.

---

### Verification
1. Press **`SUPER` + `ALT` + `3`** to switch to Scrolling layout.
2. Verify active workspace and window width:
   ```bash
   hyprctl -j clients | jq '.[] | select(.workspace.id == 1) | {title, size, at}'
   ```
   Window size reflects `1612` (85%) with clean side placement and zero over-zooming.
3. Cycle column widths with **`SUPER` + `R`** or navigate columns with **`SUPER` + `L` / `SUPER` + `H`** (or **`SUPER` + `Left` / `Right`**).

---

## BUG-04: VLC Video Pinned to Top-Left Corner with Black Right/Bottom Margins on Wayland

### Overview
When launching **VLC 3.x (Qt5)** on Hyprland — especially by opening a video from **Nautilus** or another D-Bus-activated file manager — the outer Qt window and menu/playback controls tile and scale properly, but the rendered video frame is pinned to the top-left corner inside the video pane, leaving solid black margins along both the right side and the bottom of the widget.

### Root Cause
1. **Missing `DISPLAY` in D-Bus / Systemd Activation Environment**:
   - `config/hypr/lua/startup.lua` exported `WAYLAND_DISPLAY`, `HYPRLAND_INSTANCE_SIGNATURE`, and `XDG_CURRENT_DESKTOP` via `dbus-update-activation-environment --systemd` and `systemctl --user import-environment`, but omitted `DISPLAY`.
   - File managers started over D-Bus (`nautilus --gapplication-service`) therefore lacked `DISPLAY` in their environment when spawning VLC.
2. **Qt5 Wayland `wl_subsurface` Resize Bug in VLC 3.x**:
   - With `DISPLAY` unset (or without `QT_QPA_PLATFORM=xcb`), VLC 3's Qt5 UI loads `libqwayland-generic.so` and renders video through an embedded `egl_wl` (`wl_subsurface`).
   - VLC 3's Qt5 `wl_subsurface` does not track tiled/resized Hyprland surface geometry cleanly, leaving the video subsurface smaller than the `VideoWidget` container and pinned at `(0, 0)` with black dead space on the right and bottom.

---

### The Fix (Auto-Applied): Force Qt5 VLC onto XWayland (`xcb`) + Propagate `DISPLAY`

1. **VLC Wrapper Runner (`config/hypr/scripts/vlc-runner.sh`)**:
   - Recovers `DISPLAY` from `/tmp/.X11-unix/X*` if unset (covering D-Bus launches without restarting the session).
   - Exports `QT_QPA_PLATFORM="xcb"` whenever `DISPLAY` is available so Qt5 loads `libqxcb.so` and uses an X11 `VideoWidget` with GLX output and automatic hardware decode (VDPAU/VAAPI).
   - Resolves and executes the underlying system `vlc` binary without recursion.

2. **Startup D-Bus Environment Sync (`config/hypr/lua/startup.lua`)**:
   - Included `DISPLAY` in both `dbus-update-activation-environment --systemd` and `systemctl --user import-environment` at Hyprland startup so Nautilus and user services always receive `DISPLAY`.

3. **Installer Integration (`scripts/lib_copy.sh`)**:
   - Added `install_vlc_wrapper()` so `copy.sh` automatically makes `vlc-runner.sh` executable, links `~/.local/bin/vlc`, and generates `~/.local/share/applications/vlc.desktop` pointing `Exec=` to `vlc-runner.sh` (preserving system MIME types and categories), then refreshes the desktop database via `update-desktop-database`.

---

### Verification
1. Open a video from Nautilus or launch `vlc` from Rofi/terminal.
2. Verify VLC runs under XWayland and fills its full container:
   ```bash
   hyprctl -j clients | jq '.[] | select(.class == "vlc") | {pid, class, size, xwayland}'
   ```
   `"xwayland"` reports `true` and the video frame fills 100% of the VLC viewport with zero top-left pinning or black right/bottom margins.
