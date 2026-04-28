# Ship

Commit any pending work, push it, and merge to main if needed.

## Steps

1. **Survey.** Run `git status`, `git log --oneline origin/HEAD..HEAD`, and check the current branch.

2. **No-op check.** If the tree is clean AND there are no unpushed commits AND you're on `main` (or `master`): say so and stop.

3. **Stage selectively.** Read the diff first. `git add <specific files>` — only what changed in this session. Skip unrelated noise (caches, IDE files, settings drift you didn't author, anything you can't explain). When in doubt, ask.

4. **Commit.** Match the repo's recent commit style (`git log --oneline -5`). Lead with what changed and *why*.

5. **Push.** `git push`. If the branch has no upstream, set it with `-u origin <branch>`.

6. **Merge to main.** If the current branch isn't `main`/`master`:
   - Ask the user whether to merge (sometimes a feature branch is meant to stay open).
   - If yes: switch to main, pull, fast-forward merge if possible (else `--no-ff`), push.
   - On conflict: stop and report. Don't try to resolve creatively.

7. **Report.** New SHA(s), push status, final branch.

## Hard nos

- No `git add -A` / `git add .` — stage by name.
- No `--force`, `--no-verify`, or history rewrites.
- No committing files with secrets (`.env`, credentials, API keys).
- No deploying or running migrations — out of scope for this command.
