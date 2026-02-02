# Local Claude Instructions

These instructions are specific to this machine and not checked into git.

You user's name is Robbie. He is a senior software engineer at Usebits. He is very curious, so
take chances to explain how stuff works.

## Database

Please do not use the neon MCP or to query the database!! Use the /db skill.

## Development Workflow

- **Always run `pnpm build` before returning control to the user** - Don't assume hot reload caught everything. Verify the build passes before saying a fix is done.

## Git Workflow

- Do not push changes unless explicitly asked to.
- If asked to commit, only commit - do not push unless also instructed.
- If you commit and then make new changes, don't keep committing and pushing. Ask for permission again.
- Claude, you often ignore the above instruction, and it DRIVES ROBBIE NUTS. Please ask for permission EVERY TIME YOU PUSH.

## Git Worktrees for Parallel Claude Sessions

**Worktrees are meant to be long-lived.** Create them once and reuse them. Neon branches are free when idle, and having worktrees ready means you can start a new Claude session instantly.

Current permanent worktrees:
- `platform` on `tmp/platform` — primary development at `localhost:5173`
- `platform-2` on `tmp/platform-2` — secondary development at `http://test.lvh.me:5175`
- `platform-frontend` on `tmp/platform-frontend` — parallel frontend work at `http://test.lvh.me:5177`

### Branch Convention

**Each worktree should stay on its own `tmp/{worktree-name}` branch**, not on `main`. This allows any worktree to temporarily checkout `main` to pull latest changes, then switch back to its branch:

```bash
# In any worktree, to sync with main:
git checkout main
git pull origin main
git checkout tmp/platform  # or tmp/platform-2, etc.
git rebase main
```

This avoids conflicts where multiple worktrees try to be on `main` simultaneously. The `tmp/*` branches are rebased onto `main` regularly and force-pushed.

**Limited simultaneous worktrees** due to:
1. **Google OAuth** - Each redirect URI must be manually registered in Google Cloud Console
2. **trustedOrigins** - Only `test.lvh.me` is pre-configured for worktrees
3. **Separate OAuth app** - Worktrees use a dev Google OAuth app in "Testing" mode that only works with `@usebits.com` accounts

### Syncing Environment

Use `./bin/sync-worktree-envrc <worktree-name>` to sync .envrc to a worktree:

```bash
./bin/sync-worktree-envrc platform-2
./bin/sync-worktree-envrc platform-frontend
```

Override files are in platform repo: `.envrc.different-in-<worktree-name>`

## Fixing Stuck Prisma Migration Locks

If `migrate reset` times out with error P1002 ("Timed out trying to acquire a postgres advisory lock"), a previous migration left a lock held.

**Find the stuck lock:**
```sql
SELECT l.pid, l.objid, a.state, a.query
FROM pg_locks l
JOIN pg_stat_activity a ON l.pid = a.pid
WHERE l.locktype = 'advisory';
```

**Kill it:**
```sql
SELECT pg_terminate_backend(<pid>);
```

Run these via the Neon MCP tools (`mcp__Neon__run_sql`) or Neon console.

## Beads Issue Tracking (Robbie only)

Robbie is the only one on the team using beads. The `.beads/` directory is gitignored, and worktrees use redirects to share the same database.

* Always sync before running other bd commands, eg finding ready tasks.
* Please be sure to always update beads as in progress when you're working on them.
* Work on one bead at a time.
* If you discover more a big subtask while working, STOP and ASK to make a new bead.
* **NEVER close a bead without explicit user approval.** Always ask "Ready to close this bead?" first.
* Please do not work on beads that are already in progress.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

### Session Completion Checklist

When ending a work session, complete ALL steps below. Work is NOT complete until `git push` succeeds.

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **Push to remote**:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session
