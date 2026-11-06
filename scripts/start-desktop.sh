#!/data/data/com.termux/files/usr/bin/bash
# Starts the agent's Linux desktop: Termux:X11 display :1 running an XFCE session.
# Safe to run again: it skips the start if the display is already up.
DISPLAY_NUM=":1"

if pgrep -f "termux-x11.*${DISPLAY_NUM}" >/dev/null; then
  echo "Desktop already running on ${DISPLAY_NUM}"
else
  termux-x11 "${DISPLAY_NUM}" -xstartup "dbus-launch --exit-with-session xfce4-session" >/dev/null 2>&1 &
  echo "Started desktop on ${DISPLAY_NUM}"
fi

# Bring the Termux:X11 app to the front so you can watch the desktop.
am start -n com.termux.x11/.MainActivity >/dev/null 2>&1 || \
  echo "Open the Termux:X11 app to see the desktop."
