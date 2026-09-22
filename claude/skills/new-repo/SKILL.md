---
name: new-repo
description:
  Create a new private GitHub repo under ~/repos/ pre-loaded with a template CLAUDE.md, AGENTS.md
  symlink, .gitignore, direnv, and a scaffolded Python (uv/ruff/ty) or TypeScript (pnpm/biome)
  toolchain that match Robbie's conventions. Use when the user runs /new-repo or asks to bootstrap
  a new project.
---

# New Repo

Creates a private GitHub repo under `~/repos/<name>/` with a template `CLAUDE.md`, an
`AGENTS.md -> CLAUDE.md` symlink, `.gitignore`, direnv, Markdown-only Prettier config, and a
scaffolded toolchain for Python, TypeScript, or both. The template `CLAUDE.md` imports
`~/.claude/personal-repo-rules.md`, so the personal-repo conventions (notes layout, `CODE_SMELL.md`,
Ruff, `prd`) apply without copying them into each repo.

## Arguments

`/new-repo <name> [<description>] [--python|--ts|--both]`

- `<name>` — required. Becomes the GitHub repo slug AND the local directory name under `~/repos/`.
- `<description>` — optional. One-sentence description for the GitHub repo metadata and the top of
  `CLAUDE.md`. If omitted, ask the user before proceeding.
- `--python` / `--ts` / `--both` — which toolchain to scaffold. If omitted, ask. New repos are
  basically always Python or TypeScript; anything else needs an explicit reason from Robbie.

## Stack decisions (why these tools)

- **Python:** `uv` for env + deps, `ruff` for lint + format (line length 140), `ty` for type
  checking. `ty` over pyright because it's the same Astral family as ruff/uv, installs as a single
  binary via `uv add --dev` (pyright needs Node), and is what `~/repos/silkworm` already uses. If
  `ty` chokes on something, swapping to pyright is a one-line change; don't pre-empt it.
- **TypeScript:** `pnpm` (never npm/yarn), `biome` for lint + format (not ESLint/Prettier — matches
  sapient/platform), strict `tsconfig`.
- **Markdown:** Prettier, Markdown-only, 100 cols, `proseWrap: always`. Biome can't wrap prose, so
  Prettier fills exactly that gap. Keep the options in sync with `~/repos/dotfiles/.prettierrc.json5`.
- **Tests:** none by default. Robbie doesn't want a test suite until a repo is roughly > 50k LOC.
  Don't scaffold pytest/vitest; verify changes by running the thing.
- **direnv:** `.envrc` committed, `.envrc.local` gitignored for secrets/machine-specific values.

## Steps

1. **Validate.** Confirm `<name>` is a valid-looking repo slug (lowercase, kebab-case, no spaces).
   If it's not, warn and ask. Confirm `<description>` and the toolchain flag are known; ask if not.
2. **Check for collision.** If `~/repos/<name>` already exists locally, stop and surface it — don't
   overwrite.
3. **Create + clone** in one step:
   ```bash
   cd ~/repos && gh repo create <name> --private --clone --description "<description>"
   ```
4. **Write the common files** in `~/repos/<name>/` from the templates below: `CLAUDE.md`,
   `.gitignore`, `.prettierrc.json5`, `.envrc`. Substitute `<name>`, `<description>`, and delete the
   Stack bullets for the toolchain you didn't scaffold.
5. **Create `AGENTS.md` symlink:**
   ```bash
   cd ~/repos/<name> && ln -s CLAUDE.md AGENTS.md
   ```
6. **Scaffold Python** (if `--python` or `--both`). Write `pyproject.toml` from the template, then:
   ```bash
   cd ~/repos/<name>
   uv python pin 3.12          # writes .python-version
   uv add --dev ruff ty        # creates .venv, uv.lock
   mkdir -p src/<name_snake>   # package name: <name> with - → _
   touch src/<name_snake>/__init__.py
   uv run ruff check . && uv run ty check
   ```
7. **Scaffold TypeScript** (if `--ts` or `--both`). Write `package.json`, `tsconfig.json`, and
   `biome.json` from the templates, then:
   ```bash
   cd ~/repos/<name>
   node -v | sed 's/^v//' > .nvmrc
   pnpm add -D typescript @biomejs/biome prettier
   mkdir -p src && printf 'export {};\n' > src/index.ts
   pnpm check
   ```
   For `--both`, the Prettier `overrides` block in `.prettierrc.json5` keeps Prettier off code so it
   never fights Biome; ruff owns Python.
8. **direnv:** `cd ~/repos/<name> && direnv allow`.
9. **Initial commit + push:**
   ```bash
   cd ~/repos/<name>
   git add -A
   git branch -M main
   git commit -m "Initial commit"
   git push -u origin main
   ```
   `.gitignore` already excludes `.venv/`, `node_modules/`, and `.envrc.local`, so `git add -A` is
   safe. Lockfiles (`uv.lock`, `pnpm-lock.yaml`) ARE committed.
10. **Report back:** print the local path (`~/repos/<name>`), the GitHub URL
    (`gh repo view <name> --json url -q .url`), and which toolchain was scaffolded.

## Template: `CLAUDE.md`

```markdown
# <name>

<description>

@~/.claude/personal-repo-rules.md

`AGENTS.md` at the repo root is a symlink to `CLAUDE.md` so Codex/other agents see the same
instructions. Do not replace it with a separate file.

## Stack

- Python: `uv` for deps/venv, `ruff` for lint + format (line length 140), `ty` for types. Run
  `uv run ruff check . && uv run ruff format . && uv run ty check` before shipping.
- TypeScript: `pnpm` only (never npm/yarn), `biome` for lint + format (not ESLint/Prettier). Run
  `pnpm check` before shipping.
- Markdown: Prettier, 100 cols, `proseWrap: always`. Prettier is Markdown-only here.
- Tests: none until this repo is roughly > 50k LOC. Verify by running the code, not by adding a
  test suite. If a test would genuinely save time, ask first.
- Secrets/machine-specific env go in `.envrc.local` (gitignored), never `.envrc`.

## Notes

Durable lessons about this repo go in git:

- **One-line rules** → this file (`CLAUDE.md`), or `CLAUDE.local.md` for machine-specific
  (gitignored).
- **Longer reference docs** (5–300 lines) → `.claude/notes/*.md`, with a one-line index entry below.
- **Local-only docs** (not in git) → `.claude/notes/local/*.md`.

See `~/.claude/personal-repo-rules.md` (imported above) for the full convention.

Current notes:
<!-- As notes are added under .claude/notes/, list them here, one per line: -->
<!-- - [Title — when to read](.claude/notes/foo.md) — short gloss -->
```

## Template: `.gitignore`

```
# Local Claude config — machine/personal-specific, not shared
CLAUDE.local.md
.claude/notes/local/

# direnv secrets / machine-specific
.envrc.local

# Python
.venv/
__pycache__/
*.pyc
.ruff_cache/

# Node
node_modules/
dist/

# Standard OS/editor noise
.DS_Store
*.swp
.idea/
.vscode/
```

## Template: `.envrc`

```bash
[ -f .venv/bin/activate ] && source .venv/bin/activate
source_env_if_exists .envrc.local
```

(Keep the first line even in TS-only repos; it's a no-op without a venv and saves an edit later.)

## Template: `.prettierrc.json5`

```json5
// Prettier here is MARKDOWN-ONLY. Biome owns TS/JS formatting; ruff owns Python.
// KEEP the md options in sync with ~/repos/dotfiles/.prettierrc.json5
{
  overrides: [{ files: "*.md", options: { printWidth: 100, proseWrap: "always" } }],
}
```

## Template: `pyproject.toml`

```toml
[project]
name = "<name>"
version = "0.1.0"
description = "<description>"
requires-python = ">=3.12"
dependencies = []

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/<name_snake>"]

[tool.ruff]
line-length = 140

[tool.ruff.lint]
extend-select = ["I"]   # isort — ruff owns import ordering too
```

## Template: `package.json`

```json
{
  "name": "<name>",
  "version": "0.1.0",
  "description": "<description>",
  "private": true,
  "type": "module",
  "scripts": {
    "check": "biome check . && tsc --noEmit",
    "fix": "biome check --write ."
  }
}
```

(`pnpm add -D` in step 7 fills in `devDependencies` and `packageManager`.)

## Template: `tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "skipLibCheck": true,
    "outDir": "dist"
  },
  "include": ["src"]
}
```

## Template: `biome.json`

```json
{
  "$schema": "https://biomejs.dev/schemas/2.4.11/schema.json",
  "vcs": { "enabled": true, "clientKind": "git", "useIgnoreFile": true },
  "files": { "includes": ["**", "!**/.claude", "!**/dist"] },
  "formatter": { "enabled": true, "indentStyle": "space", "indentWidth": 2 },
  "linter": { "enabled": true, "rules": { "recommended": true } },
  "javascript": { "formatter": { "quoteStyle": "double" } },
  "assist": { "enabled": true, "actions": { "source": { "organizeImports": "on" } } }
}
```

(Schema version: use whatever `pnpm add -D @biomejs/biome` installed; check
`node_modules/@biomejs/biome/package.json` and update the `$schema` line to match.)

## Don't

- Don't run this against a non-empty existing directory — stop and tell the user.
- Don't create the repo as public — Robbie's default for new repos is private.
- Don't create `AGENTS.md` as a regular file — it should be a symlink to `CLAUDE.md` so Codex/other
  agents see the same instructions.
- Don't use ESLint/Prettier for code, npm/yarn, pyright, mypy, or pip/poetry. The stack above is the
  stack.
- Don't scaffold a test framework, CI, README, license, pre-commit/lefthook, or Dockerfile. Robbie
  adds what he actually needs.
- Don't skip the confirmation on `<description>` or the toolchain flag if they weren't supplied —
  both are annoying to change later.
