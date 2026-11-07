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

## 🌐 Chromium & Browser Wayland Optimization

- **Zero Glitch Guarantee**: Pre-configured browser flags for **Brave**, **Google Chrome**, and **Chromium** (`brave-flags.conf`, `chrome-flags.conf`, `chromium-flags.conf`).
- **ANGLE OpenGL Fallback**: Eliminates texture corruption, black rectangular scanlines, and image glitching on Wayland (particularly on Intel/NVIDIA hybrid laptops).
- **Smooth Wayland Window Decorations**: Seamless window management and fractional scaling integration.
- **Troubleshooting Reference**: Documented solutions in [`bugs.md`](./bugs.md) for quick diagnosis and browser flag tuning.

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

## 🚀 Hyprland Lua VM & User Config Architecture

- **Lua-Powered Configuration**: Fast, type-safe, and modular Hyprland configuration system.
- **Protected User Space**: Personal tweaks live in `~/.config/hypr/UserConfigs/` and are preserved during dotfiles updates.
- **Cheat Sheet**: Press **`SUPER` + `H`** to open the interactive KeyHints cheat sheet.
- **Quick Settings**: Press **`SUPER` + `SHIFT` + `E`** to access the system settings menu (theming, animations, display profiles, default apps).

