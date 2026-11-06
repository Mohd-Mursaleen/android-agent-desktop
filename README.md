# android-agent-desktop

Give your AI agent its own computer, on the same Android phone it runs on.

This is the setup behind iota, my personal agent. iota runs on a 2018 OnePlus 6 inside Termux. This repo adds a real Linux desktop (XFCE) to that phone, plus a Chromium browser the agent can drive. You can watch the desktop in the Termux:X11 app while the agent works.

```
Android phone
└── Termux (Linux userland)
    ├── your agent (Hermes, OpenClaw, anything)
    ├── Termux:X11 display :1
    │   └── XFCE desktop
    │       └── Chromium  ── CDP on 127.0.0.1:9222 ──┐
    └── agent drives the browser through CDP  ◄───────┘
```

No root. No proot distro. No laptop. Tested on a OnePlus 6 (Snapdragon 845, 8 GB RAM).

## What you need

- An Android phone (8 GB RAM is comfortable, 6 GB works for light use)
- [Termux](https://github.com/termux/termux-app) from F-Droid or GitHub (not the Play Store build)
- [Termux:X11](https://github.com/termux/termux-x11/releases) app (the APK from its releases page)
- [Termux:Boot](https://github.com/termux/termux-boot) from F-Droid, only if you want it to start after a reboot
- Node.js + pm2, only if you want services to restart on their own

## 1. Install

```sh
git clone https://github.com/Mohd-Mursaleen/android-agent-desktop
cd android-agent-desktop
bash scripts/install.sh
```

This installs the X11 and TUR repos, then `termux-x11-nightly`, `xfce4`, `xfce4-terminal`, `dbus` and `chromium`. It takes a while on a phone, so keep it on charge.

## 2. Start the desktop

```sh
bash scripts/start-desktop.sh
```

It starts display `:1` with an XFCE session and opens the Termux:X11 app. You should see a desktop with a taskbar. That is your agent's computer.

## 3. Start the agent's browser

```sh
bash scripts/start-chromium-cdp.sh
```

Chromium opens on the desktop with remote control (CDP) on `127.0.0.1:9222`. It uses its own profile in `~/.agent-browser`, separate from anything you use yourself. CDP only listens on localhost, so nothing is exposed to your network.

Check it:

```sh
curl -s http://127.0.0.1:9222/json/version
python examples/open_url.py https://www.youtube.com
```

The second command opens a new tab on the phone's desktop. If you see it in Termux:X11, the whole chain works.

## 4. Point your agent at it

Any CDP client can now drive the browser: click, type, read pages, take screenshots.

- **Hermes Agent**: `hermes config set browser.cdp_url http://127.0.0.1:9222`
- **Any other agent or script**: connect to `http://127.0.0.1:9222` with a CDP library (for example Puppeteer `connect({ browserURL })` or Playwright `connect_over_cdp`).

Now "open the latest video on YouTube" happens on the agent's own screen, not yours.

## 5. Keep it running (optional)

Android likes to kill background apps. Three things fix that:

```sh
npm install -g pm2
pm2 start ecosystem.config.js     # restarts Chromium if it crashes
pm2 save

mkdir -p ~/.termux/boot
cp scripts/boot.sh ~/.termux/boot/agent-desktop
chmod +x ~/.termux/boot/agent-desktop
```

`boot.sh` takes a wake lock, starts the desktop and runs `pm2 resurrect` after the phone restarts. Also turn off battery optimisation for Termux, Termux:X11 and Termux:Boot in Android settings.

If you close the Chromium window by hand, pm2 leaves it closed. Run `pm2 restart agent-browser` to bring it back.

## Troubleshooting

| Problem | Fix |
|---|---|
| Black screen in Termux:X11 | Run `start-desktop.sh` again. Check `pgrep -f "termux-x11.*:1"` |
| `curl` on port 9222 fails | Desktop must be up first. Chromium waits for display `:1` |
| Chromium says profile is in use | `rm ~/.agent-browser/SingletonLock` |
| Desktop dies when the screen is off | Battery optimisation is still on for Termux apps |
| dbus or NetworkManager errors in the log | Harmless on Termux |

## What this does not do

This gives the agent a computer. Controlling normal Android apps (Rapido, Swiggy, any app) is a separate layer: an accessibility service to read the screen and ADB to tap and type. I write about that part in the blog post.

## Blog

The full story, in plain words: [geekymd.me/blog](https://geekymd.me/blog)

## License

MIT
