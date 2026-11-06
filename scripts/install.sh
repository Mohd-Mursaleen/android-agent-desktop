#!/data/data/com.termux/files/usr/bin/bash
# Installs a Linux desktop (XFCE on Termux:X11) and Chromium inside Termux.
set -e

if [ -z "$PREFIX" ] || [ ! -d "$PREFIX/bin" ]; then
  echo "Run this inside Termux." >&2
  exit 1
fi

pkg update -y
pkg install -y x11-repo tur-repo
pkg update -y
pkg install -y termux-x11-nightly xfce4 xfce4-terminal dbus chromium curl python

echo
echo "Done. Also install the Termux:X11 Android app from:"
echo "  https://github.com/termux/termux-x11/releases"
echo "Next: bash scripts/start-desktop.sh"
