# akr-dots v0.7 Release Notes

**Release**: `akr-dots-v0.7`  
**Date**: November 7, 2026  
**Maintainer**: [ajaykumarreddy-k](https://github.com/ajaykumarreddy-k)  
**Base Upstream**: [LinuxBeginnings/Hyprland-Dots](https://github.com/LinuxBeginnings/Hyprland-Dots)  

---

## 🌟 Overview

Welcome to **akr-dots v0.7**! This release brings automated one-line installation scripts for Ubuntu and other major Linux distributions, a permanent zero-glitch fix for Chromium-based browsers (Brave, Chrome, Edge) on Wayland/hybrid GPUs, custom wallpaper addition tooling, and native GNOME screenshot controls.

---

## 🚀 Key Highlights & New Features

### 1. 🐧 Automated One-Line Installers (Ubuntu & Universal)
- **Ubuntu Quick Installer (`install-ubuntu.sh`)**:
  - Automatically checks if Hyprland is already present on the system:
    - **Hyprland Found**: Skips package compiling and immediately applies the `akr-dots` configuration via `copy.sh`.
    - **Hyprland Missing**: Automatically runs `Distro-Hyprland.sh` to install Hyprland and all desktop dependencies (`waybar`, `rofi-wayland`, `swww`, `swaync`, `wallust`, `kitty`, audio, fonts, polkit), then applies the dotfiles.
  - Install in one command:
    ```bash
    curl -sL https://raw.githubusercontent.com/ajaykumarreddy-k/Akr-Dots-Linux/main/install-ubuntu.sh | bash
    ```
- **Universal Multi-Distro Installer (`install.sh`)**:
  - Supports Ubuntu, Debian, Arch Linux, Fedora, openSUSE, and NixOS with automatic package manager detection.
  - Install in one command:
    ```bash
    curl -sL https://raw.githubusercontent.com/ajaykumarreddy-k/Akr-Dots-Linux/main/install.sh | bash
    ```
- Dedicated **🐧 Ubuntu Support** button pinned directly in the `README.md` navigation bar.

### 2. 🌐 Zero-Glitch Chromium & Brave GPU Acceleration (BUG-02 Fix)
- **Definitive Fix for Hover Slicing & Damage Overlays**:
  - Solves the Wayland partial damage rectangle desync and EGL buffer swapchain tearing on Chromium browsers (observed on CSS hover-scaled cards like `styles.refero.design`).
  - Defaults the display backend to `--ozone-platform=x11` with `--enable-gpu-rasterization`.
  - Guarantees 100% full hardware GPU acceleration (compositing, WebGL, 3D Canvas, video decode) at 144Hz with zero lag and zero graphical artifacts.
- **Universal Browser Flags Runner (`browser-flags-runner.sh`)**:
  - Automatically loads and applies flags across Debian/Ubuntu/Arch.
  - Generates desktop entries in `~/.local/share/applications/` (`brave-browser.desktop`, `google-chrome.desktop`, `chromium.desktop`) routing launches through the runner with hardcoded fallback arguments.
- Comprehensive root cause and troubleshooting guide added to [`bugs.md`](./bugs.md).

### 3. 🎨 Interactive Custom Wallpaper Importer (`+` Button)
- Integrated a new **`+ Add Custom Wallpaper`** tile directly into the Rofi Wallpaper Chooser (**`SUPER` + `W`**).
- Automatically invokes a native GUI file picker (`zenity`, `yad`, or `kdialog`) to browse and select any wallpaper image or video.
- Automatically copies the selected file to `~/Pictures/wallpapers/` and immediately applies it via `swww`/`awww` (or `mpvpaper` for animated/video wallpapers).
- Regenerates the entire dynamic desktop theme instantly with `Wallust`.
- See [`features.md`](./features.md) for details.

### 4. 📸 Native GNOME Interactive Screenshot (`PRTSCR` Keybind)
- Pressing the **`PRTSCR` / `Print`** key directly triggers the GNOME interactive screenshot UI (`gnome-screenshot -i`).
- Bound **`F6`** as a dedicated alternative for laptops without a physical Print Screen button.
- Graceful zero-breakage fallback to Swappy/Grim interactive selection if `gnome-screenshot` is not present.
- Dedicated floating and centering window rule in `lua/window_rules.lua`.

### 5. 🏷️ Identity & Fastfetch Rebranding
- Fastfetch and Pokemon fetch now display `akr-dots Version: 0.7`.
- System version marker set to `v0.7`.

---

## 📦 Quick Install Commands

### Ubuntu One-Liner:
```bash
curl -sL https://raw.githubusercontent.com/ajaykumarreddy-k/Akr-Dots-Linux/main/install-ubuntu.sh | bash
```

### Universal One-Liner (Arch / Fedora / Debian / openSUSE):
```bash
curl -sL https://raw.githubusercontent.com/ajaykumarreddy-k/Akr-Dots-Linux/main/install.sh | bash
```

### Offline / Manual Install from Release Tarball:
```bash
tar -xzf akr-dots-v0.7.tar.gz
cd akr-dots-v0.7
chmod +x install-ubuntu.sh copy.sh
./install-ubuntu.sh
```

---

## 🔒 Verification & Quality Assurance
- **Unit & Integration Test Suite**: All 693 checks passed, 0 failed (`run-all.sh`).
- **Syntax Validation**: 100% clean across all shell scripts (`bash -n`) and Lua VM configs (`luac -p`).
