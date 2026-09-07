# Claude Code Settings

## This repo is public

Assume anything committed here is world-readable. Notes that name real infrastructure — AWS
account IDs, root emails, IAM users, bucket names, work hosts, billing accounts — go in the
private companion repo instead:

- `~/repos/dotfiles-private/claude-notes/` → symlinked to `~/.claude/.claude/notes/`
- Created by `bin/setup-symlinks.sh`, which clones the private repo if it is missing and skips
  the symlink gracefully if you have no access to it.

It is a separate **repo**, not a gitignored directory, because gitignored files do not sync
between machines — and that is exactly why the notes ended up in the public repo the first time.

On 2026-09-07 `claude/.claude/notes/` and `claude/projects/` were purged from this repo's entire
history with `git filter-repo` and the result was force-pushed. Any clone from before that date has
divergent history and must be re-cloned; `git pull --ff-only` will refuse to update it.

## Important: Edit Files in This Repo!

The following files are **symlinked** from `~/.claude/` to this dotfiles repo:

- `~/.claude/settings.json` → `~/repos/dotfiles/claude/settings.json`
- `~/.claude/CLAUDE.md` → `~/repos/dotfiles/claude/CLAUDE.md`
- `~/.claude/skills` → `~/repos/dotfiles/claude/skills`
- `~/.claude/plugins/blocklist.json` → `~/repos/dotfiles/claude/plugins/blocklist.json`
- `~/.claude/plugins/config.json` → `~/repos/dotfiles/claude/plugins/config.json`

**Always edit the files in `~/repos/dotfiles/`**, not in `~/.claude/`! Except for
`~/.claude/settings.local.json` which is machine-specific.

## File Purposes

### `claude/settings.json`

Global Claude Code settings shared across all your machines. Edit this file for permissions,
auto-updates, and other global config.

### `claude/CLAUDE.md`

Global instructions for Claude Code that apply to all projects. Edit this file to customize Claude's
behavior across all your repos.

### `claude/plugins/`

Only the small declarative manifests are tracked and symlinked: `blocklist.json` and `config.json`.
The rest of `~/.claude/plugins/` (`cache/`, `marketplaces/`, `installed_plugins.json`,
`known_marketplaces.json`) is auto-managed runtime state that Claude Code regenerates per machine,
so it is deliberately NOT tracked.

### `~/.claude/settings.local.json` (NOT symlinked)

Machine-specific overrides that stay local to each computer. Use this for settings unique to one
machine only.

## What's NOT Tracked

The following stay local and are NOT in this repo:

- `~/.claude/history.jsonl` - Command history
- `~/.claude/debug/` - Debug logs
- `~/.claude/file-history/` - File history
- `~/.claude/shell-snapshots/` - Shell snapshots
- Other runtime data

These are ephemeral/machine-specific and shouldn't be synced.
