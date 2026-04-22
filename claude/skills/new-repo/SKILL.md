---
name: new-repo
description: Create a new private GitHub repo under ~/repos/ pre-loaded with a template CLAUDE.md and .gitignore that match Robbie's notes-in-git conventions. Use when the user runs /new-repo or asks to bootstrap a new project.
---

# New Repo

Creates a private GitHub repo under `~/repos/<name>/` with a template `CLAUDE.md` and `.gitignore` already set up per Robbie's notes conventions (see `~/.claude/CLAUDE.md` § Memory and notes).

## Arguments

`/new-repo <name> [<description>]` — both positional:
- `<name>` — required. Becomes the GitHub repo slug AND the local directory name under `~/repos/`.
- `<description>` — optional. One-sentence description for the GitHub repo metadata and the top of `CLAUDE.md`. If omitted, ask the user before proceeding.

## Steps

1. **Validate.** Confirm `<name>` is a valid-looking repo slug (lowercase, kebab-case, no spaces). If it's not, warn and ask.
2. **Check for collision.** If `~/repos/<name>` already exists locally, stop and surface it — don't overwrite.
3. **Create + clone** in one step:
   ```bash
   cd ~/repos && gh repo create <name> --private --clone --description "<description>"
   ```
4. **Write `CLAUDE.md`** at `~/repos/<name>/CLAUDE.md` using the template below. Substitute `<name>` and `<description>`.
5. **Write `.gitignore`** at `~/repos/<name>/.gitignore` using the template below. This keeps `CLAUDE.local.md` and `.claude/notes/local/` out of git.
6. **Initial commit + push:**
   ```bash
   cd ~/repos/<name>
   git add CLAUDE.md .gitignore
   git branch -M main
   git commit -m "Initial commit"
   git push -u origin main
   ```
7. **Report back:** print the local path (`~/repos/<name>`) and the GitHub URL (`gh repo view --web --json url -q .url` or just `gh repo view <name> --json url -q .url`).

## Template: `CLAUDE.md`

```markdown
# <name>

<description>

## Notes

Durable lessons about this repo go in git:
- **One-line rules** → this file (`CLAUDE.md`), or `CLAUDE.local.md` for machine-specific (gitignored).
- **Longer reference docs** (5–300 lines) → `.claude/notes/*.md`, with a one-line index entry below.
- **Local-only docs** (not in git) → `.claude/notes/local/*.md`.

See `~/.claude/CLAUDE.md` for the full convention.

Current notes:
<!-- As notes are added under .claude/notes/, list them here, one per line: -->
<!-- - [Title — when to read](.claude/notes/foo.md) — short gloss -->
```

## Template: `.gitignore`

```
# Local Claude config — machine/personal-specific, not shared
CLAUDE.local.md
.claude/notes/local/

# Standard OS/editor noise
.DS_Store
*.swp
.idea/
.vscode/
```

## Don't

- Don't run this against a non-empty existing directory — stop and tell the user.
- Don't create the repo as public — Robbie's default for new repos is private.
- Don't add a README.md, license, or any other files beyond `CLAUDE.md` + `.gitignore`. Keep the bootstrap minimal; Robbie adds what he actually needs.
- Don't skip the confirmation on `<description>` if it wasn't supplied — the description lands in GitHub metadata and at the top of `CLAUDE.md`, both annoying to change later.
