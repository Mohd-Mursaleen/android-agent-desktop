// pm2 config: keeps the agent's browser alive.
// Usage: pm2 start ecosystem.config.js && pm2 save
const path = require("path");

module.exports = {
  apps: [
    {
      name: "agent-browser",
      script: path.join(__dirname, "scripts/start-chromium-cdp.sh"),
      interpreter: "bash",
      // Exit code 0 means you closed the window yourself, so don't reopen it.
      stop_exit_codes: [0],
      restart_delay: 5000,
    },
  ],
};
