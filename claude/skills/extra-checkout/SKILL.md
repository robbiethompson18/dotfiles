---
name: extra-checkout
description:
  Create additional full checkouts of an existing repo (repo-2, repo-3, …) for parallel agent work,
  symlinking gitignored local config back to the main checkout. Use when the user asks for another
  checkout/clone of a repo (NOT a worktree), like platform-2 or sapient-2.
---

# Extra Checkout

Creates `~/repos/<repo>-N` as a **full separate clone** (own `.git`, same `origin`) of
`~/repos/<repo>`, then symlinks gitignored-but-needed local files back to the main checkout. Robbie
explicitly does NOT use git worktrees for this — other agents share checkouts, and worktrees are
banned in his global config.

Existing examples of this pattern: `platform-2`, `silkworm-2`, `sapient-2`/`sapient-3`.

## Arguments

`/extra-checkout <repo> [<n>]` — `<repo>` is the directory name under `~/repos/`; `<n>` is how many
new checkouts (default 1). Numbering continues from the highest existing suffix (`repo` → `repo-2` →
`repo-3`).

## Steps

1. **Find the origin URL** from the main checkout: `git -C ~/repos/<repo> remote get-url origin`. If
   the target dir `~/repos/<repo>-N` already exists, stop and surface it.
2. **Clone:**
   ```bash
   cd ~/repos && git clone <origin-url> <repo>-N
   ```
3. **Identify local files to symlink.** In the main checkout, list gitignored config that the repo
   needs to run but git doesn't carry:
   ```bash
   git -C ~/repos/<repo> status --porcelain --ignored | grep '^!!'
   ```
   Typical candidates: `.envrc` (if gitignored — in some repos it's tracked), `.envrc.local`,
   `CLAUDE.local.md`, `.claude/settings.local.json`, `docs/local/` (or legacy `.claude/notes/local/`). Skip build outputs,
   `node_modules/`, caches, and local app state (`data/`, `tmp/`) — those regenerate or shouldn't be
   shared.
4. **Symlink each candidate**, preferring relative links:
   ```bash
   ln -s ../<repo>/.envrc.local ~/repos/<repo>-N/.envrc.local
   ```
5. **direnv allow** the new checkout: `direnv allow ~/repos/<repo>-N`.
6. **Install deps** with whatever the repo uses (`pnpm install`, etc.) and run any required codegen
   (e.g. `prisma generate`) to verify the checkout actually works. For npm/yarn repos (no
   `pnpm-lock.yaml`), first APFS-clone the main checkout's `node_modules` so the new checkout shares
   its disk blocks instead of writing a ~1 GB copy, then use `npm install`, not `npm ci` (`ci` deletes
   `node_modules` first, throwing the clones away):
   ```bash
   cp -c -R ~/repos/<repo>/node_modules ~/repos/<repo>-N/ && (cd ~/repos/<repo>-N && npm install)
   ```
   Repeat for workspace-level `node_modules` dirs (e.g. `apps/*/node_modules`) if the main checkout
   has them. uv venvs and pnpm already share blocks with their global caches; nothing to do there.
7. **Report back:** path of each new checkout, what was symlinked, and the port-conflict caveat
   below if it applies.

## Port / DB conflicts (important caveat)

A symlinked `.envrc.local` means **identical env** across checkouts. If the env contains ports or a
DATABASE_URL, the checkouts cannot run dev servers simultaneously and will share one database. Two
resolutions, by precedent:

- **Symlink anyway** (sapient): fine when `.envrc.local` only holds secrets (API keys) and parallel
  agents mostly edit/build/test rather than serve.
- **Divergent copy** (platform-2): give the new checkout its own real `.envrc.local` with unique
  ports, its own DB branch/org, etc. If picking new ports, consult and update the port registry in
  the `caddy` skill.

Default to the symlink and mention the caveat; only diverge if the user wants concurrent dev
servers.

## Don't

- Don't use `git worktree`.
- Don't copy secrets into new files when a symlink works — one source of truth.
- Don't symlink `data/` or other mutable local app state without asking.
