# Claude Code Settings

## Important: Edit Files in This Repo!

The following files are **symlinked** from `~/.claude/` to this dotfiles repo:
- `~/.claude/settings.json` → `~/repos/dotfiles/claude-settings.json`
- `~/.claude/plugins/` → `~/repos/dotfiles/claude-plugins/`

**Always edit the files in `~/repos/dotfiles/`**, not in `~/.claude/`! Except for `~/.claude/settings.local.json` which is machine-specific.

## File Purposes

### `claude-settings.json`
Global Claude Code settings shared across all your machines.
Edit this file for permissions, auto-updates, and other global config.

### `~/.claude/settings.local.json` (NOT symlinked)
Machine-specific overrides that stay local to each computer.
Use this for settings unique to one machine only.

### `claude-plugins/`
Plugin configurations, MCP servers, skills, and hooks.
Symlinked so your plugins/skills are consistent across machines.

## What's NOT Tracked

The following stay local and are NOT in this repo:
- `~/.claude/history.jsonl` - Command history
- `~/.claude/debug/` - Debug logs
- `~/.claude/file-history/` - File history
- `~/.claude/shell-snapshots/` - Shell snapshots
- Other runtime data

These are ephemeral/machine-specific and shouldn't be synced.
