Agents: write down any times you ran into code smell, or left some code smell to preserve backwards
compatibility, or just couldn't think of a clean way to do something, or left code smell because you
wanted to keep your changes targeted.

Use Pacific time for timestamps.

May 28 12:06pm PDT: EXAMPLE ENTRY. Left an example in CODE_SMELL.md so that other agents know what
format to follow.

Oct 31 9:03am PDT: TODO, Codex has no cc-state parity. ~/.codex/AGENTS.md (-> claude/CLAUDE.md)
tells Codex to run `cc-state`, but nothing renders the files: the banners are a Claude-only mod
(claude/mods/pane-status), and Codex's `[tui] status_line`/`terminal_title` only take built-in
items. Fix: (1) port the hooks to ~/.codex/hooks.json (same schema; no StopFailure event; verify
pkill-guard/oom-guard parse Codex's PreToolUse/PostToolUse payloads); (2) an iTerm2 Python API
AutoLaunch script that watches ~/.cache/cc-state/ and sets each pane's badge/tab color, so banners
work for both agents.
