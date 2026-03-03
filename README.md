# Claude Statusline Pro

A rich, colorized status bar for Claude Code that displays key session info at a glance.

## What it shows

```
📁 my-project/ │ 🌿 main │ ⏱️ 12m │ Claude Opus 4.6 │ ████░░░░░░ 150k / 1m
```

- **Project directory** (cyan) - current project folder name
- **Git branch** (green) - active branch when in a git repo
- **Session time** (yellow) - how long the current session has been running
- **Model name** (magenta) - which Claude model is active
- **Context usage bar** (green/yellow/red) - visual progress bar with token counts
  - Green: < 50% used
  - Yellow: 50-75% used
  - Red: > 75% used

## Install

Add the marketplace in Claude Code:

```
/plugin marketplace add adulvac/claude-statusline-pro
```

Then enable the plugin from the Discover tab (`/plugin` > Discover).

## Requirements

- `jq` must be installed (`brew install jq` on macOS, `apt install jq` on Linux)
- `git` for branch detection

## Customization

After installing, you can fork the repo and modify `scripts/statusline.sh` to add or remove components, change colors, or adjust the context bar thresholds.

## License

MIT
