[![jp](https://img.shields.io/badge/lang-jp-blue.svg)](./i18n/README/README.jp.md)
[![ro](https://img.shields.io/badge/lang-ro-green.svg)](./i18n/README/README.ro.md)
[![ru](https://img.shields.io/badge/lang-ru-red.svg)](./i18n/README/README.ru.md)
[![ua](https://img.shields.io/badge/lang-ua-white.svg)](./i18n/README/README.ua.md)
[![de](https://img.shields.io/badge/lang-de-magenta.svg)](./i18n/README/README.de.md)
[![fr](https://img.shields.io/badge/lang-fr-cyan.svg)](./i18n/README/README.fr.md)

<h1 align="center">akr-dots</h1>

<p align="center">
  <b>Personal, refined Hyprland Dotfiles</b><br>
  Maintained and customized by <a href="https://github.com/ajaykumarreddy-k"><b>ajaykumarreddy-k</b></a>
</p>

<p align="center">
  <img src="assets/latte.png" width="400" alt="akr-dots preview" />
</p>

> [!NOTE]
> **Main Source / Attribution**: This codebase is derived from and based on the upstream [`LinuxBeginnings/Hyprland-Dots`](https://github.com/LinuxBeginnings/Hyprland-Dots) (`dots-main`).
> It is independently maintained, customized, and bugfixed by [ajaykumarreddy-k](https://github.com/ajaykumarreddy-k).

---

<div align="center">
  <a href="#-installationupdate-instructions"><kbd>&emsp;<br>&emsp;Installation&emsp;<br>&emsp;</kbd></a>&ensp;&ensp;
  <a href="#-multi-monitor-display-layouts"><kbd>&emsp;<br>&emsp;Display Layouts&emsp;<br>&emsp;</kbd></a>&ensp;&ensp;
  <a href="#-keybinds"><kbd>&emsp;<br>&emsp;Keybinds&emsp;<br>&emsp;</kbd></a>&ensp;&ensp;
  <a href="CHANGELOG.md"><kbd>&emsp;<br>&emsp;Changelog&emsp;<br>&emsp;</kbd></a>
</div>

---

### 🪧 Attention

- This repository contains pre-configured Hyprland dotfiles and configurations.
- Packages are not installed by `copy.sh` alone — Hyprland and associated desktop packages (waybar, rofi, swww/swaybg, etc.) must be installed on your system.

### 💥 Installation / Setup Instructions

> [!NOTE]
> The auto-copy script `copy.sh` creates backups of your existing configs before modifying anything.

#### 1. Clone the repository

```bash
git clone --depth=1 https://github.com/ajaykumarreddy-k/Akr-Dots-Linux.git && cd Akr-Dots-Linux
```

#### 2. Run the copy script

```bash
chmod +x copy.sh
./copy.sh
```

#### ⚠️ Backups Created by Script

> [!CAUTION]
> `copy.sh` creates timestamped backups in `~/.config/hypr/UserConfigs` and other target config folders.
> You can manually verify or prune unwanted backups in `$HOME/.config`.

#### 🛎️ A Note on Wallpapers

- By default, standard curated wallpapers are copied (dark, light, and select aesthetics).
- You will be prompted if you wish to download additional wallpapers.

#### ⚠️ Post-Installation Tips

- **NVIDIA GPU Users**:
  - Review `~/.config/hypr/UserConfigs/user_env.lua` and adjust hardware acceleration flags as needed.
- **Hybrid Intel/NVIDIA or AMD/NVIDIA Laptops**:
  - XCURSOR fallbacks and startup cursor refresh are automatically handled.
- **Custom Keybinds & Monitor Layouts**:
  - Customize your personal rules in `~/.config/hypr/UserConfigs/`.

### 🖥️ Multi-Monitor Display Layouts

- Remembers how you arrange your monitors (by hardware identity, not by port) and restores the arrangement automatically for any set of connected screens — laptop or desktop, any number of monitors, with lid/clamshell handling and `nwg-displays` integration.
- Press **`SUPER` + `ALT` + `D`** to open the layout menu.
- Quick Settings (**`SUPER` + `SHIFT` + `E`**) &rarr; **Choose Monitor Profiles** lists saved layouts.
- Stored cleanly in `UserConfigs/monitors.lua`.
- Full architecture and usage guide: [`README-display-layouts.md`](./README-display-layouts.md).

### ⌨ Keybinds

- Press **`SUPER` + `H`** at any time to open the Quick Cheat Sheet / KeyHints menu.
- See [`docs/Keybinds.md`](./docs/Keybinds.md) for the complete list of default shortcuts.

### 📄 License

Licensed under the [GNU General Public License v3.0](LICENSE.md).
Based upon original work by [LinuxBeginnings](https://github.com/LinuxBeginnings/Hyprland-Dots).
