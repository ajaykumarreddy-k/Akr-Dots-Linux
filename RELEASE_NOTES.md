# akr-dots v0.6 Release Notes

**Release**: `akr-dots-v0.6`  
**Date**: November 7, 2026  
**Maintainer**: [ajaykumarreddy-k](https://github.com/ajaykumarreddy-k)  
**Base Upstream**: [LinuxBeginnings/Hyprland-Dots](https://github.com/LinuxBeginnings/Hyprland-Dots)  

---

## 🌟 Overview

Welcome to the initial independent release of **akr-dots v0.6**! This release establishes `akr-dots` as a self-maintained, customized Hyprland dotfiles distribution featuring personal refinements, out-of-the-box hardware fixes, and new interactive desktop tooling.

---

## 🚀 Key Highlights & New Features

### 1. 🎨 Interactive Custom Wallpaper Importer (`+`)
- Integrated a new **`+ Add Custom Wallpaper`** tile directly into the Rofi Wallpaper Chooser (**`SUPER` + `W`**).
- Automatically invokes a native GUI file picker (`zenity`, `yad`, or `kdialog`) to browse and select any wallpaper image or video.
- Automatically copies the selected file to `~/Pictures/wallpapers/` and immediately applies it via `swww`/`awww` (or `mpvpaper` for animated/video wallpapers).
- Regenerates the entire dynamic desktop theme instantly with `Wallust`.
- See [`features.md`](./features.md) for details.

### 2. 🌐 Chromium & Brave Wayland Fix (BUG-01)
- Fixed image glitching, corrupted horizontal scanlines, and black texture boxes in Chromium-based browsers (Brave, Google Chrome, Chromium, Edge) on Wayland.
- Ships pre-configured flag files: `brave-flags.conf`, `chrome-flags.conf`, `chromium-flags.conf` utilizing ANGLE OpenGL fallback (`--use-angle=gl`).
- Automatically deploys flags to `~/.config/` via `copy.sh`.
- Full Q&A troubleshooting guide documented in [`bugs.md`](./bugs.md).

### 3. 📸 Native GNOME Interactive Screenshot (`PRTSCR` Keybind)
- Pressing the **`PRTSCR` / `Print`** key directly triggers the GNOME interactive screenshot UI (`gnome-screenshot -i`).
- Bound **`F6`** as a dedicated alternative for laptops without a physical Print Screen button.
- Graceful zero-breakage fallback to Swappy/Grim interactive selection if `gnome-screenshot` is not present.
- Dedicated floating and centering window rule in `lua/window_rules.lua`.

### 4. 🏷️ Identity & Fastfetch Rebranding
- Full independence and rebranding across system configs, banners, update utilities, and fastfetch modules.
- Fastfetch and Pokemon fetch now display `akr-dots Version: 0.6`.

### 5. 📚 New Documentation Hub
- Added [`features.md`](./features.md): Comprehensive feature breakdown and tooling guide.
- Added [`bugs.md`](./bugs.md): Tested bug fixes, root causes, and Q&A solutions.
- Updated [`README.md`](./README.md) with quick links and root repository attribution.

---

## 📦 Installation & Setup

### Option A: Install from Release Tarball
```bash
tar -xzf akr-dots-v0.6.tar.gz
cd akr-dots-v0.6
chmod +x copy.sh
./copy.sh
```

### Option B: Clone via Git
```bash
git clone --depth=1 https://github.com/ajaykumarreddy-k/Akr-Dots-Linux.git
cd Akr-Dots-Linux
chmod +x copy.sh
./copy.sh
```

---

## 🔒 Verification & Quality Assurance
- **Unit & Integration Test Suite**: 693 checks, 0 failed (`run-all.sh`).
- **Syntax Validation**: 100% clean across all shell scripts (`bash -n`) and Lua VM configs (`luac -p`).
