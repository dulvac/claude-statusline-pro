---
name: setup
description: Enable or disable the statusline-pro status bar in your global Claude Code settings
---

# Statusline Pro Setup

Configure the statusline-pro status bar in the user's global Claude Code settings (`~/.claude/settings.json`).

## Instructions

You MUST follow these steps exactly:

### Step 1: Determine intent

Look at the user's message. If they said "disable", "remove", "uninstall", or "off", go to the **Disable** section. Otherwise, go to the **Enable** section.

---

### Enable

1. Read the file `~/.claude/settings.json`. If the file does not exist, that's fine — treat it as an empty JSON object `{}`.

2. Check if the JSON already contains a `"statusLine"` key.

3. **If `statusLine` already exists**, ask the user:
   > Your global settings already have a statusLine configuration. Do you want to overwrite it with statusline-pro?

   If the user says no, stop and say the setup was cancelled. If yes, continue.

4. Add or replace the `"statusLine"` key in the JSON with this exact value:
   ```json
   "statusLine": {
     "type": "command",
     "command": "bash ~/.claude/plugins/marketplaces/claude-statusline-pro/scripts/statusline.sh",
     "padding": 0
   }
   ```

   **Preserve all other existing keys** in the file. Only touch the `statusLine` key.

5. Tell the user:
   > Statusline Pro has been enabled! Restart Claude Code or start a new session to see it.

---

### Disable

1. Read the file `~/.claude/settings.json`. If the file does not exist, tell the user there's nothing to disable and stop.

2. Check if the JSON contains a `"statusLine"` key.

3. If there is no `statusLine` key, tell the user the statusline is already disabled and stop.

4. Remove the `"statusLine"` key from the JSON. Preserve all other keys.

5. Tell the user:
   > Statusline Pro has been disabled. The status bar will return to default on your next session.
