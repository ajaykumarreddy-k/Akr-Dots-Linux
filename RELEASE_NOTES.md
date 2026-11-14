# akr-dots v0.8 Release Notes

**Release**: `akr-dots-v0.8`  
**Date**: November 14, 2026  
**Maintainer**: [ajaykumarreddy-k](https://github.com/ajaykumarreddy-k)  
**Repository**: [ajaykumarreddy-k/Akr-Dots-Linux](https://github.com/ajaykumarreddy-k/Akr-Dots-Linux)  
**Base Upstream**: [LinuxBeginnings/Hyprland-Dots](https://github.com/LinuxBeginnings/Hyprland-Dots)  

---

## 🌟 Overview

Welcome to **akr-dots v0.8**! This release isolates the dotfiles update system exclusively to the `akr-dots` repository to eliminate spurious notifications from upstream, introduces a definitive zero-glitch fix for VLC media player on Wayland, optimizes Hyprland Scrolling layout to 85% column width with smooth side peeking, and bundles automated one-line installers for Ubuntu and major Linux distributions.

---

## 🚀 Key Highlights & New Features

### 1. 🔄 Independent `akr-dots` Update Channel
- **Isolated Dotfiles Updater (`KooLsDotsUpdate.sh` & `AkrDotsUpdate.sh`)**:
  - Locked update comparison and changelog URLs strictly to `ajaykumarreddy-k/Akr-Dots-Linux`.
  - Upstream Kool repository releases (e.g. `v2.3.28+`) will **never** trigger false update notifications or prompt for unwanted upstream changes.
  - Live cache-busting on GitHub raw requests ensures immediate, accurate update detection when new `akr-dots` releases are published.
  - Automatically synced into `~/.config/hypr/scripts/` during installation and upgrades.

### 2. 🎬 Zero-Glitch VLC Media Player on Wayland (BUG-04 Fix)
- **Definitive Fix for Cropped Video Surface**:
  - Solves the VLC 3.x Qt5 `wl_subsurface` bug where video was pinned to the top-left corner leaving black margins on the right and bottom.
  - Deployed `vlc-runner.sh` wrapper forcing XWayland (`QT_QPA_PLATFORM=xcb`) with full GLX and VDPAU/VAAPI hardware acceleration.
  - Automatically recovers `DISPLAY` when launched from D-Bus file managers (Nautilus) and imports `DISPLAY` and `PATH` into user session environments.
  - Automatically generates `~/.local/share/applications/vlc.desktop` and symlinks `~/.local/bin/vlc` on login and installer copy.

### 3. 📜 Scrolling Layout Optimization & 0.85 Tape Width (BUG-03 Fix)
- **Balanced 85% Column Width**:
  - Active windows take **85%** of the screen width (`column_width = 0.85`), leaving an elegant **15%** side-peek on the scrolling tape.
  - Disabled single-column fullscreen blowup (`fullscreen_on_one_column = false`).
  - Added `0.85` column width preset to `window_actions.lua` (**`SUPER` + `R`**).
  - Fixed regex matching in `PersistWorkspaceLayout.sh` so custom workspace layouts persist reliably across reboots.

### 4. 🐧 Automated One-Line Installers (Ubuntu & Universal)
- **Ubuntu Quick Installer (`install-ubuntu.sh`)**:
  - Checks if Hyprland is already present: skips compiling if found, or automatically compiles and installs Hyprland and all desktop dependencies via `Distro-Hyprland.sh`.
  - Install in one command:
    ```bash
    curl -sL https://raw.githubusercontent.com/ajaykumarreddy-k/Akr-Dots-Linux/main/install-ubuntu.sh | bash
    ```
- **Universal Multi-Distro Installer (`install.sh`)**:
  - Auto-detects package managers across Ubuntu, Debian, Arch Linux, Fedora, openSUSE, and NixOS.
  - Install in one command:
    ```bash
    curl -sL https://raw.githubusercontent.com/ajaykumarreddy-k/Akr-Dots-Linux/main/install.sh | bash
    ```

### 5. 🌐 Zero-Glitch Chromium & Brave GPU Acceleration (BUG-02 Fix)
- Defaults browser backend to `--ozone-platform=x11` with `--enable-gpu-rasterization` to eliminate Wayland partial damage rectangle desync and hover card overlay tearing.
- Full hardware acceleration with zero lag at 144Hz.

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
tar -xzf akr-dots-v0.8.tar.gz
cd akr-dots-v0.8
chmod +x install-ubuntu.sh copy.sh
./install-ubuntu.sh
```

---

## 🔒 Verification & Quality Assurance
- **Unit & Integration Test Suite**: All 693 checks passed, 0 failed (`run-all.sh`).
- **Syntax Validation**: 100% clean across all shell scripts (`bash -n`) and Lua VM configs (`luac -p`).
