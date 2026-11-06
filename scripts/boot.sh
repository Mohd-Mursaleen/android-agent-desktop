#!/data/data/com.termux/files/usr/bin/bash
# Termux:Boot script. Copy to ~/.termux/boot/ to bring everything back after a phone restart.
# Termux:Boot starts without termux-exec, so "#!/usr/bin/env node" tools (pm2) can't run.
# Re-exec once with the preload set from the start.
TX="$PREFIX/lib/libtermux-exec-ld-preload.so"
[ -z "$PREFIX" ] && TX=/data/data/com.termux/files/usr/lib/libtermux-exec-ld-preload.so
if [ -z "$AGENT_BOOT_REEXEC" ] && [ -f "$TX" ]; then
  export AGENT_BOOT_REEXEC=1 LD_PRELOAD="$TX" PATH="/data/data/com.termux/files/usr/bin:$PATH"
  exec "$0" "$@"
fi

LOG="$HOME/.agent-desktop-boot.log"
exec >>"$LOG" 2>&1
echo "=== boot $(date '+%F %T')"

# Stop Android from putting Termux to sleep.
termux-wake-lock

# Desktop first, then let pm2 bring back the browser (and your agent, if pm2 runs it).
if ! pgrep -f "termux-x11.*:1" >/dev/null; then
  termux-x11 :1 -xstartup "dbus-launch --exit-with-session xfce4-session" >/dev/null 2>&1 &
fi
command -v pm2 >/dev/null && pm2 resurrect

echo "=== boot done $(date '+%F %T')"
