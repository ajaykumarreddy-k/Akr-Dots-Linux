#!/usr/bin/env bash
# Wrapper for VLC 3.x (Qt5) under Hyprland / Wayland.
#
# VLC 3's Qt5 Wayland video surface (wl_subsurface / egl_wl) fails to track
# dynamic tiled window bounds cleanly, pinning video to the top-left corner
# with black right/bottom margins. Forcing Qt onto XWayland (QT_QPA_PLATFORM=xcb)
# restores proper VideoWidget sizing and GLX/VDPAU/VAAPI output.
set -uo pipefail

SELF_PATH="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || printf '%s' "${BASH_SOURCE[0]}")"

resolve_real_vlc() {
  local cand resolved
  for cand in /usr/bin/vlc /usr/local/bin/vlc /snap/bin/vlc; do
    if [[ -x "$cand" ]]; then
      resolved="$(readlink -f "$cand" 2>/dev/null || printf '%s' "$cand")"
      if [[ "$resolved" != "$SELF_PATH" ]]; then
        printf '%s\n' "$cand"
        return 0
      fi
    fi
  done

  while IFS= read -r cand; do
    [[ -n "$cand" ]] || continue
    resolved="$(readlink -f "$cand" 2>/dev/null || printf '%s' "$cand")"
    if [[ "$resolved" != "$SELF_PATH" ]]; then
      printf '%s\n' "$cand"
      return 0
    fi
  done < <(which -a vlc 2>/dev/null)

  return 1
}

REAL_VLC="$(resolve_real_vlc)" || {
  echo "vlc-runner: real vlc binary not found" >&2
  exit 127
}

# Recover DISPLAY when launched from a D-Bus service (e.g. Nautilus) that lacks it.
if [[ -z "${DISPLAY:-}" ]]; then
  for sock in /tmp/.X11-unix/X*; do
    [[ -S "$sock" ]] || continue
    export DISPLAY=":${sock##*/X}"
    break
  done
fi

if [[ -n "${DISPLAY:-}" ]]; then
  export QT_QPA_PLATFORM="xcb"
fi

exec "$REAL_VLC" "$@"

