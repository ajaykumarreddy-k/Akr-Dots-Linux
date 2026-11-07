#!/usr/bin/env bash
# ==================================================
#  akr-dots — Universal Multi-Distro Automated Installer
#  Maintainer: ajaykumarreddy-k
#  Repository: https://github.com/ajaykumarreddy-k/Akr-Dots-Linux
#  Supported: Ubuntu, Debian, Arch Linux, Fedora, openSUSE, NixOS
#  License: GNU GPLv3
# ==================================================
set -euo pipefail

# Guard against running as root
if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  echo "Error: Please run this script as a normal user with sudo privileges, NOT as root." >&2
  exit 1
fi

DOTS_REPO="https://github.com/ajaykumarreddy-k/Akr-Dots-Linux.git"
CLONE_DIR="${HOME}/Akr-Dots-Linux"

echo "=========================================================="
echo "  🚀 akr-dots — Universal Multi-Distro Installer"
echo "=========================================================="

# 1. Detect package manager and ensure git + curl
if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
  echo ">> Installing required tools (git, curl)..."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y git curl
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm git curl
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y git curl
  elif command -v zypper >/dev/null 2>&1; then
    sudo zypper install -y git curl
  else
    echo "Warning: Unknown package manager. Please ensure git and curl are installed manually." >&2
  fi
fi

# 2. Clone or update repository
if [ -d "$CLONE_DIR/.git" ]; then
  echo ">> Existing repository found at $CLONE_DIR. Pulling latest changes..."
  git -C "$CLONE_DIR" pull --rebase
else
  echo ">> Cloning akr-dots to $CLONE_DIR..."
  rm -rf "$CLONE_DIR"
  git clone "$DOTS_REPO" "$CLONE_DIR"
fi

cd "$CLONE_DIR"
chmod +x Distro-Hyprland.sh copy.sh config/hypr/scripts/browser-flags-runner.sh

# 3. Check for Hyprland installation
if command -v Hyprland >/dev/null 2>&1 || command -v hyprland >/dev/null 2>&1; then
  echo ""
  echo ">> Hyprland is already installed on this system!"
  echo ">> Skipping package build and applying akr-dots dotfiles directly..."
  ./copy.sh
else
  echo ""
  echo ">> Hyprland not detected. Launching distribution installer (Distro-Hyprland.sh)..."
  ./Distro-Hyprland.sh
fi

echo ""
echo "=========================================================="
echo "  ✅ akr-dots installation completed successfully!"
echo "  Reboot or log out, click the gear icon on login, and select Hyprland."
echo "=========================================================="

