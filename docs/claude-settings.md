# Claude Code settings in this repo

## This repo is public

Assume anything committed here is world-readable. Notes that name real infrastructure (AWS account
IDs, root emails, IAM users, bucket names, work hosts, billing accounts) go in the private companion
repo `~/repos/dotfiles-private/claude-notes/`, symlinked to `~/.claude/docs/` by
`bin/setup-symlinks.sh`, which clones the private repo if missing and skips the symlink if you have
no access.

It is a separate repo, not a gitignored directory, because gitignored files do not sync between
machines, which is exactly how the notes ended up in the public repo the first time.

On 2026-09-07 `claude/.claude/notes/` and `claude/projects/` were purged from this repo's history
with `git filter-repo` and force-pushed. Any clone from before that date has divergent history and
must be re-cloned; `git pull --ff-only` will refuse to update it.

## Edit files here, not in ~/.claude

`bin/setup-symlinks.sh` links these into each of `~/.claude`, `~/.claude-work` and `~/.claude-spar`
(one dir per login; Claude Code keys the Keychain credential, `.claude.json` and session history to
`CLAUDE_CONFIG_DIR`):

- `settings.json` → `claude/settings.json`: permissions, env vars, hooks, model, plugins.
- `CLAUDE.md` → `claude/CLAUDE.md`: global instructions. Also linked as `AGENTS.md` into
  `~/.codex` and `~/.codex-work`.
- `personal-repo-rules.md` → `claude/personal-repo-rules.md`: imported by personal repos' CLAUDE.md.
- `skills/` → `claude/skills/`. Mirrored into Codex by `bin/sync-codex-claude-skills`.
- `docs/` → `~/repos/dotfiles-private/claude-notes/` (private).
- `plugins/blocklist.json`, `plugins/config.json` → `claude/plugins/`. The rest of
  `~/.claude/plugins/` (`cache/`, `marketplaces/`, `installed_plugins.json`,
  `known_marketplaces.json`) is runtime state Claude Code regenerates per machine.

`~/.claude/settings.local.json` is not symlinked; it holds machine-specific overrides.

## Local mods

`claude/mods/` holds local plugins (`now-doing`, `pane-status`), loaded via
`CLAUDE_CODE_PLUGIN_DIRS` in `claude/settings.json`.
