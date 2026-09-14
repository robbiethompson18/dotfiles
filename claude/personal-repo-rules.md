# Personal-repo conventions

> Rules that apply in repos Robbie owns, not in work repos. Pulled into each personal repo's
> `CLAUDE.md` via `@~/.claude/personal-repo-rules.md`. Global rules that apply everywhere live in
> `~/.claude/CLAUDE.md`.

## Memory and notes

Durable context lives in git, not in Claude Code's machine-local memory system. Storage locations,
by content type:

- **One-line behavioral rules** (dos/don'ts, conventions) → the current repo's `CLAUDE.md`, or
  `CLAUDE.local.md` for machine-specific/personal rules (gitignored).
- **Longer reference docs** (5–300 lines: incident writeups, architecture, gotchas, repros) →
  `.claude/notes/*.md` in the current repo.
- **Cross-project rules** → `~/.claude/CLAUDE.md` (global) or this file (personal repos only). Only
  when Robbie explicitly asks — don't assume something is global.

Every file in `.claude/notes/` must be indexed by a one-line reference under a `## Notes` section in
the nearest `CLAUDE.md`, so future sessions know the file exists:

```
- [Title — when to read this](.claude/notes/thing.md) — short gloss of contents
```

Kebab-case filenames (`thing-name.md`, not `thing_name.md`).

Behavioral rules (one-liners) do **not** go into notes files — notes are lazy-loaded, but behavioral
rules need to always apply, so they go directly in `CLAUDE.md`.

Agents underuse `CODE_SMELL.md`; when you notice or leave debt, add a dated note to the current
repo's top-level `CODE_SMELL.md` instead of relying on memory.

## Shipping

If asked to ship any changes, also ship unstaged or committed changes to markdown files, possibly in
a separate commit. Do not worry about stashing these changes.

When working in `/Users/robbie/repos/dotfiles`, after making a change, you are welcome to ship it
without waiting for a separate ship request.

## Other agents

Other agents might be editing the same checkout as you. Do not use worktrees. Don't stash changes of
a live working agent. Depending on the repo and context, the best course is one of:

1. Create a fresh checkout of the repo
2. Just keep working in the same checkout, ship everything all at once with little regard for clean
   commits
3. Ship existing work, discard it, or put it on a closed PR.

If it's not obvious which, ask Robbie.

## Tooling

- Use Ruff exclusively for Python linting and formatting.
- Repos use `.envrc` and `.envrc.local` (direnv).

## Development server

- Robbie will typically use `prd` to start the dev server.
- This runs `pnpm run dev` and logs output to a directory-specific path.
- Logs are written to `/tmp{PWD minus HOME}/dev-output.log` (e.g., `~/repos/platform` →
  `/tmp/repos/platform/dev-output.log`).
- These are **local dev server logs only**, not production logs. There is no access to production
  logs from here.
- You should check these logs when you're helping the user debug local dev issues.
- To find the log file for the current project, check `/tmp/repos/<project-name>/dev-output.log`.
