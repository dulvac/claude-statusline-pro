# Design: `/statusline-pro:setup` Slash Command

## Goal

Add a slash command that configures the user's global `~/.claude/settings.json` to use the statusline-pro statusline, and can also disable it.

## Approach

Plugin Skill — a `skills/setup/SKILL.md` file that auto-registers as `/statusline-pro:setup`.

## Behavior

### Enable (default)

1. Read `~/.claude/settings.json` (create if missing)
2. Check if `statusLine` key exists
3. If exists: ask user before overwriting
4. Write the `statusLine` config:
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/plugins/marketplaces/claude-statusline-pro/scripts/statusline.sh",
       "padding": 0
     }
   }
   ```
5. Confirm success

### Disable

1. Read `~/.claude/settings.json`
2. Remove the `statusLine` key
3. Confirm removal

## Files

- **New**: `skills/setup/SKILL.md`
- No other files need changes

## Constraints

- Preserve all other keys in the settings file
- Use `Read` and `Edit` tools only
- Path uses marketplace install location convention
