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

sync_vlc_desktop() {
  local bin_dir="$HOME/.local/bin"
  local app_dir="$HOME/.local/share/applications"
  local target_desktop="$app_dir/vlc.desktop"
  local src_desktop="" cand

  mkdir -p "$bin_dir" "$app_dir"
  ln -sf "$SELF_PATH" "$bin_dir/vlc" 2>/dev/null || true

  resolve_real_vlc >/dev/null 2>&1 || return 0

  # Fast path: desktop override already points Exec= to this wrapper
  if [[ -f "$target_desktop" ]] && grep -qFx "Exec=$SELF_PATH --started-from-file %U" "$target_desktop" 2>/dev/null; then
    return 0
  fi

  for cand in /usr/share/applications/vlc.desktop /var/lib/snapd/desktop/applications/vlc_vlc.desktop; do
    if [[ -f "$cand" ]]; then
      src_desktop="$cand"
      break
    fi
  done

  if [[ -n "$src_desktop" ]]; then
    sed -e "s|^Exec=.*|Exec=$SELF_PATH --started-from-file %U|" \
        -e "s|^TryExec=.*|TryExec=$SELF_PATH|" \
        "$src_desktop" | tr -d '\r' > "$target_desktop"
  else
    cat > "$target_desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=VLC media player
GenericName=Media player
Comment=Read, capture, broadcast your multimedia streams
Exec=$SELF_PATH --started-from-file %U
TryExec=$SELF_PATH
Icon=vlc
Terminal=false
Type=Application
Categories=AudioVideo;Player;Recorder;
MimeType=application/ogg;application/x-ogg;audio/ogg;video/ogg;video/x-msvideo;video/mp4;video/x-m4v;video/quicktime;application/x-matroska;audio/x-matroska;video/x-matroska;video/webm;video/x-flv;audio/mpeg;audio/flac;audio/wav;
Keywords=Player;Capture;DVD;Audio;Video;Server;Broadcast;
EOF
  fi

  update-desktop-database "$app_dir" 2>/dev/null || true
}

if [[ "${1:-}" == "--sync-desktop" ]]; then
  sync_vlc_desktop
  exit 0
fi

REAL_VLC="$(resolve_real_vlc)" || {
  echo "vlc-runner: real vlc binary not found" >&2
  exit 127
}

sync_vlc_desktop

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
