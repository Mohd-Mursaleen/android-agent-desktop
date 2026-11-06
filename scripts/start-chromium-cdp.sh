#!/data/data/com.termux/files/usr/bin/bash
# Starts the agent's browser on the desktop with CDP (remote control) on 127.0.0.1:9222.
# Waits until the X11 display is up, so pm2 or boot can start it early.
PORT="${CDP_PORT:-9222}"
PROFILE="${AGENT_BROWSER_PROFILE:-$HOME/.agent-browser}"
SOCK="$PREFIX/tmp/.X11-unix/X1"

until [ -S "$SOCK" ] && pgrep -f "termux-x11.*:1" >/dev/null; do
  echo "Waiting for desktop on :1 (run scripts/start-desktop.sh)..."
  sleep 10
done

mkdir -p "$PROFILE"
rm -f "$PROFILE/SingletonLock"
export DISPLAY=:1

chromium-browser \
  --remote-debugging-port="$PORT" \
  --remote-debugging-address=127.0.0.1 \
  --user-data-dir="$PROFILE" \
  --no-first-run --no-default-browser-check \
  about:blank
rc=$?

# Closed by hand (normal quit or signal): exit 0 so pm2 leaves it closed.
# A real crash (any other code) is passed through, so pm2 restarts it.
case $rc in 0|130|143) exit 0 ;; *) exit $rc ;; esac
