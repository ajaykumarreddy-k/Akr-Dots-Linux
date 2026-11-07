# Features — akr-dots

A comprehensive overview of features, enhancements, and custom tooling in **akr-dots**.

---

## 🎨 Wallpaper Engine & Custom Wallpaper Import (`+`)

akr-dots includes an interactive Wallpaper Selector (**`SUPER` + `W`**) with dynamic Wallust color theme regeneration.

### ✨ New Feature: Custom Wallpaper Import (`+` Button)
- **Direct GUI Import**: A dedicated `+ Add Custom Wallpaper` button tile is now integrated directly into the wallpaper chooser grid.
- **Universal File Picker**: Automatically launches a native GUI file selector (`zenity`, `yad`, or `kdialog`) to browse and select any image or video from your computer or downloads.
- **Wide Format Support**:
  - **Images**: PNG, JPG, JPEG, WebP, GIF, BMP, TIFF.
  - **Animated / Videos**: MP4, MKV, MOV, WebM (powered by `mpvpaper`).
- **Auto-Organization**: Automatically copies the chosen wallpaper into `~/Pictures/wallpapers/` so it is permanently preserved in your collection.
- **Instant Theming**: Immediately applies the new wallpaper via `swww`/`awww` and invokes `Wallust` to regenerate the entire desktop theme (Waybar, Rofi, Kitty, SwayNC, Ghostty) in real-time.

---

## 🌐 Chromium & Browser Hardware Acceleration & Wayland Optimization

- **Zero Glitch Guarantee (BUG-01 & BUG-02 Fixes)**: Pre-configured browser flags for **Brave**, **Google Chrome**, and **Chromium** (`brave-flags.conf`, `chrome-flags.conf`, `chromium-flags.conf`).
- **Definitive Fix for Hover Slicing & Overlays**: Default runner automatically passes `--ozone-platform=x11 --enable-gpu-rasterization`.
  - Eliminates Wayland partial damage rectangle desynchronization when hovering over CSS transform cards (`scale(1.02)` on `styles.refero.design`).
  - Completely stops image corruption, checkered static, and cards slicing into adjacent tiles.
  - Keeps 100% full hardware GPU acceleration (compositing, WebGL, 3D Canvas, video decode) at 144Hz with zero lag.
- **Universal Browser Flags Runner (`browser-flags-runner.sh`)**:
  - Automatically loads and applies flags on Debian/Ubuntu/Arch.
  - Desktop entries in `~/.local/share/applications/` route GUI launches through the runner with hardcoded fallbacks.
- **Troubleshooting Reference**: Comprehensive root causes and documentation in [`bugs.md`](./bugs.md).

---

## 📜 Scrolling Tape Layout & Dynamic Column Presets (`SUPER` + `ALT` + `3`)

- **PaperWM / Niri-Style Infinite Tape**: In addition to Dwindle and Master layouts, `akr-dots` features a native scrolling tape layout where columns flow horizontally across an infinite canvas.
- **85% Side Placement (`0.85` Column Width)**:
  - Active column defaults to **85%** of screen width, providing ample room for coding, browsing, or terminal work.
  - Leaves **15%** visible on the side for the next column on the tape, giving an intuitive visual overview of adjacent windows.
- **Disabled Single-Column Zooming**:
  - `fullscreen_on_one_column = false` prevents single windows from unexpectedly ballooning into fullscreen monocle view.
- **Dynamic Width Cycling (`SUPER` + `R`)**:
  - Quickly cycle through column width presets (`0.25`, `0.33`, `0.50`, `0.66`, `0.75`, `0.85`, `1.0`) on the active window.
- **Tape Navigation Keybinds**:
  - **`SUPER` + `H` / `L`** or **`SUPER` + `Left` / `Right`**: Focus left / right columns.
  - **`SUPER` + `SHIFT` + `period` / `comma`**: Move column right / left.
  - **`SUPER` + `ALT` + `period` / `comma`**: Swap column right / left on tape.
- **Full Details & Fixes**: Documented under **BUG-03** in [`bugs.md`](./bugs.md).

---

## 🖥️ Multi-Monitor Display Profiles

- **Hardware Identity Matching**: Remembers your monitor arrangement by hardware EDID, not fragile port names (`DP-1`, `HDMI-A-1`).
- **Automatic Restoration**: Automatically restores your preferred monitor arrangement, resolution, and refresh rate when connecting or disconnecting screens.
- **Lid & Clamshell Management**: Intelligently disables the laptop panel when closed while an external screen is active, and restores it on lid open.
- **Interactive Switcher**: Press **`SUPER` + `ALT` + `D`** to open the Display Layout Selector.

---

## ⚡ Dynamic Desktop Theming (Wallust)

- **Colors Extracted from Wallpaper**: Every time a wallpaper is selected, `Wallust` extracts a harmonious 16-color palette.
- **System-Wide Theming**: Colors propagate instantly without session restart to:
  - **Waybar**: Bar background, active workspace pills, module accents.
  - **Rofi**: Application launcher and wallpaper selection cards.
  - **Kitty & Ghostty**: Terminal color schemes.
  - **SwayNC**: Notification center cards and buttons.
  - **Wlogout**: Lock / logout dialog.

---

## 📸 Native GNOME-Style Screenshot Experience (Default `PRTSCR` Keybind)

- **Default Out-of-the-Box Behavior**: In `akr-dots`, pressing the **`PRTSCR` / `Print`** button immediately triggers the GNOME interactive screenshot interface by default—no awkward multi-key modifiers like `SUPER + Print` required.
- **Laptop Friendly (`F6` Alternative)**: For laptops and compact keyboards without a dedicated physical Print Screen button, pressing **`F6`** triggers the exact same interactive interface out of the box.
- **Full Interactive Controls**:
  - Interactively select custom rectangular screen regions, grab an active window, or capture the whole desktop.
  - Toggle cursor capture and set optional countdown delay timers.
- **Zero-Breakage Graceful Fallback**: If `gnome-screenshot` is ever missing on a minimal distro installation, `ScreenShot.sh` automatically and seamlessly falls back to Swappy/Grim interactive selection (`ScreenShot.sh --swappy`), so screenshot functionality is guaranteed 100% of the time.
- **Dedicated Floating Window Rule**: Built directly into `lua/window_rules.lua` to float and center the screenshot dialog automatically without disrupting tiled workspaces.

---

## 🚀 Automated Installers (Ubuntu & Universal Multi-Distro)

- **Ubuntu Quick Installer (`install-ubuntu.sh`)**:
  - One-line copy-paste automated installer tailored for Ubuntu:
    ```bash
    curl -sL https://raw.githubusercontent.com/ajaykumarreddy-k/Akr-Dots-Linux/main/install-ubuntu.sh | bash
    ```
  - **Smart Hyprland Check**:
    - **Hyprland Found**: Skips package compiling and immediately deploys `akr-dots` dotfiles via `copy.sh`.
    - **Hyprland Missing**: Automatically runs `Distro-Hyprland.sh` to install Hyprland and all desktop dependencies (`waybar`, `rofi-wayland`, `swww`, `swaync`, `wallust`, `kitty`, audio, fonts, polkit), then deploys the dotfiles.
  - Automatically installs prerequisite packages (`git`, `curl` via `apt`).
- **Universal Multi-Distro Installer (`install.sh`)**:
  - One-line copy-paste universal installer for any Linux distribution:
    ```bash
    curl -sL https://raw.githubusercontent.com/ajaykumarreddy-k/Akr-Dots-Linux/main/install.sh | bash
    ```
  - Automatically detects the package manager (`apt`, `pacman`, `dnf`, `zypper`).
  - Supports Ubuntu, Debian, Arch Linux, Fedora, openSUSE, and NixOS.
  - Automatically checks for existing Hyprland installations before deciding whether to run full package setup or direct dotfiles deployment.

---

## 🚀 Hyprland Lua VM & User Config Architecture

- **Lua-Powered Configuration**: Fast, type-safe, and modular Hyprland configuration system.
- **Protected User Space**: Personal tweaks live in `~/.config/hypr/UserConfigs/` and are preserved during dotfiles updates.
- **Cheat Sheet**: Press **`SUPER` + `H`** to open the interactive KeyHints cheat sheet.
- **Quick Settings**: Press **`SUPER` + `SHIFT` + `E`** to access the system settings menu (theming, animations, display profiles, default apps).

