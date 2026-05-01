---
name: ship
description: Commit pending work, push it, and merge to main. Use when Robbie asks to ship, commit, push, or merge finished changes.
---

# Ship

Commit any pending work, push it, and merge to main.

## Steps

1. Survey. Check `git status`, `git log --oneline origin/HEAD..HEAD`, and the current branch. If the tree is clean, there are no unpushed commits, and you are on main, there is nothing to ship.

2. Select files. Read the diff and choose only the files changed for this task/session. Skip unrelated noise such as caches, IDE files, settings drift you did not author, and anything you cannot explain. When in doubt, ask.

3. Commit. Match the repo's recent commit style from `git log --oneline -5`. Lead with what changed and why. Use the committer helper with explicit file paths:

   ```bash
   committer "your commit message" path/to/file1 path/to/file2
   ```

4. Sync with remote. Run `git pull --rebase` to absorb upstream commits. The tree should be clean post-commit, so no stash is needed. On conflict, stop and report.

5. Push. Run `git push`. Set upstream with `-u origin <branch>` if the branch has none.

6. Merge to main. If the current branch is not `main` or `master`, switch to main, pull, fast-forward merge if possible, otherwise use `--no-ff`, then push. Do not ask for extra permission to merge; the ship request already includes it. On conflict, stop and report.

7. Report new SHA(s), push status, and final branch.

## Hard Nos

- No `git add -A` or `git add .`; stage by name.
- No `--force`, `--no-verify`, or history rewrites.
- No committing files with secrets, such as `.env`, credentials, or API keys.
- No deploying or running migrations. Those are out of scope for this skill.
