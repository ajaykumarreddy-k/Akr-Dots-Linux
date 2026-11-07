#!/usr/bin/env bash
# ==================================================
#  akr-dots (2026)
#  Maintainer: ajaykumarreddy-k
#  Browser flags launcher wrapper for Wayland & hybrid GPU stability
# ==================================================
# Loads flags from $XDG_CONFIG_HOME/<browser>-flags.conf and launches the real browser.

cmd_name="$(basename "$0")"

browser_type=""
flags_file=""
search_bins=()

case "$cmd_name" in
  brave*|com.brave.Browser*)
    browser_type="brave"
    flags_file="${XDG_CONFIG_HOME:-$HOME/.config}/brave-flags.conf"
    search_bins=("/usr/bin/brave-browser-stable" "/opt/brave.com/brave/brave" "/usr/bin/brave" "/usr/bin/brave-browser")
    ;;
  google-chrome*|chrome*)
    browser_type="chrome"
    flags_file="${XDG_CONFIG_HOME:-$HOME/.config}/chrome-flags.conf"
    search_bins=("/usr/bin/google-chrome-stable" "/opt/google/chrome/chrome" "/usr/bin/google-chrome")
    ;;
  chromium*)
    browser_type="chromium"
    flags_file="${XDG_CONFIG_HOME:-$HOME/.config}/chromium-flags.conf"
    search_bins=("/usr/bin/chromium" "/usr/bin/chromium-browser" "/usr/lib/chromium/chromium")
    ;;
  *)
    if [ "$#" -gt 0 ]; then
      case "$1" in
        brave*)
          browser_type="brave"
          flags_file="${XDG_CONFIG_HOME:-$HOME/.config}/brave-flags.conf"
          search_bins=("/usr/bin/brave-browser-stable" "/opt/brave.com/brave/brave" "/usr/bin/brave")
          shift
          ;;
        chrome*|google-chrome*)
          browser_type="chrome"
          flags_file="${XDG_CONFIG_HOME:-$HOME/.config}/chrome-flags.conf"
          search_bins=("/usr/bin/google-chrome-stable" "/opt/google/chrome/chrome" "/usr/bin/google-chrome")
          shift
          ;;
        chromium*)
          browser_type="chromium"
          flags_file="${XDG_CONFIG_HOME:-$HOME/.config}/chromium-flags.conf"
          search_bins=("/usr/bin/chromium" "/usr/bin/chromium-browser")
          shift
          ;;
      esac
    fi
    ;;
esac

flags=()
if [ -n "$flags_file" ] && [ -f "$flags_file" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [ -n "$line" ] && flags+=("$line")
  done < "$flags_file"
fi

# Fallback defaults if flags file is empty or missing: ensure X11 and GPU rasterization
if [ "${#flags[@]}" -eq 0 ]; then
  flags=("--ozone-platform=x11" "--enable-gpu-rasterization" "--disable-features=UseChromeOSDirectVideoDecoder")
fi

real_bin=""
my_path="$(readlink -f "$0" 2>/dev/null || echo "$0")"
for candidate in "${search_bins[@]}"; do
  if [ -x "$candidate" ]; then
    candidate_real="$(readlink -f "$candidate" 2>/dev/null || echo "$candidate")"
    if [ "$candidate_real" != "$my_path" ]; then
      real_bin="$candidate"
      break
    fi
  fi
done

if [ -z "$real_bin" ] && [ -n "$browser_type" ]; then
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    candidate_real="$(readlink -f "$p" 2>/dev/null || echo "$p")"
    if [ "$candidate_real" != "$my_path" ] && [ -x "$candidate_real" ]; then
      real_bin="$candidate_real"
      break
    fi
  done < <(which -a "$cmd_name" 2>/dev/null || true)
fi

if [ -n "$real_bin" ] && [ -x "$real_bin" ]; then
  exec "$real_bin" "${flags[@]}" "$@"
else
  echo "Error: No underlying browser binary found for $cmd_name" >&2
  exit 1
fi
