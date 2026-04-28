# Ship

Commit any pending work, push it, and merge to main if needed.

## Steps

1. **Survey.** `git status`, `git log --oneline origin/HEAD..HEAD`, current branch. If the tree is clean, no unpushed commits, and you're on main: nothing to ship, stop.

2. **Stage selectively.** Read the diff. `git add <specific files>` — only what you changed this session. Skip unrelated noise (caches, IDE files, settings drift you didn't author, anything you can't explain). When in doubt, ask. You should only ship edits you made unless instructed otherwise.

3. **Commit.** Match the repo's recent commit style (`git log --oneline -5`). Lead with what changed and *why*.

4. **Sync with remote.** `git pull --rebase` to absorb any upstream commits. Tree is clean post-commit, so this is safe — no need to stash. On conflict: stop and report.

5. **Push.** `git push`. Set upstream with `-u origin <branch>` if the branch has none.

6. **Merge to main.** If the current branch isn't `main`/`master`:
   - Ask whether to merge (some feature branches are meant to stay open).
   - If yes: switch to main, pull, fast-forward merge if possible (else `--no-ff`), push.
   - On conflict: stop and report. Don't resolve creatively.

7. **Report.** New SHA(s), push status, final branch.

## Hard nos

- No `git add -A` / `git add .` — stage by name.
- No `--force`, `--no-verify`, or history rewrites.
- No committing files with secrets (`.env`, credentials, API keys).
- No deploying or running migrations — out of scope for this command.
