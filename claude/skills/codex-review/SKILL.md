---
name: codex-review
description:
  Get an OpenAI Codex review of the current change locally, in ~40s, instead of waiting for the
  Codex GitHub bot. Typically use on any PR over ~100 LOC, before or after opening it. Also handles free-text
  consults ("Codex, here's what I'm least sure about"). Codex is a different model lineage, so it
  has uncorrelated blind spots — that is the entire point.
---

# codex-review

## Why this exists

It's faster than waiting for a github PR bot.

## Usage

```bash
~/.claude/skills/codex-review/codex-review.sh [options]
```

| Invocation | What it reviews |
| --- | --- |
| `codex-review.sh` | the branch vs `main` (default) |
| `codex-review.sh --base production` | vs another base |
| `codex-review.sh --uncommitted` | staged + unstaged + untracked |
| `codex-review.sh --commit <sha>` | one commit |
| `codex-review.sh --ask "..."` | free-text consult, no review framing |
| `codex-review.sh --fix` | review, then let Codex fix its own findings (**P1 only** by default) |

Other flags: `--fix-threshold P1|P2` (default `P1`), `--account work|personal`,
`--timeout <sec>` (default 1200), `--model <name>`.

Output lands in `.git/codex-review/` — inside `.git`, so it is per-checkout and can never be
committed. `review.md` is the findings, `raw.log` the full transcript, `fix.diff` what Codex wrote.

Findings come back in the same shape as the GitHub bot: `- [P1] Title — path:lines`, then
mechanism → consequence → suggested fix.

## When to reach for it

- **On any PR over ~100 LOC**, before or after it's opened (repo rules may pick one). This is the main use.
- **While writing code** if a decision or implementation is hard and you're uncertain.


## `--fix`: rules that make it safe

Codex writing is **opt-in per invocation** and never the default.

1. **Read `.git/codex-review/fix.diff` before doing anything else.** You are about to ship code you
   did not write, under your own name. If you cannot explain a hunk in review, revert it.
2. **Revert is printed by the script** and is two commands, because a checkout restores content but
   does not delete files Codex created:
   ```
   git checkout <pre-tree> -- .
   xargs rm -f < .git/codex-review/fix.new-files
   ```
   (The checkout also stages what it restores; `git reset` after, if you care.) The pre-fix tree id
   is kept in `.git/codex-review/pre-fix-tree`.
3. **The snapshot covers everything** — tracked, staged, dirty *and* untracked — so an edit to a
   file git wasn't tracking still shows up in `fix.diff`. It is built in a side index via
   `GIT_INDEX_FILE`, so your own staged state is never disturbed.
4. **Never run `--fix` while another agent is editing the same checkout.** Ten checkouts exist so
   this does not have to happen; use a different one.
5. **Codex does not commit, stage, push, or touch git history.** The prompt forbids it. If you see
   it having done so, that is a bug in this skill — report it, don't work around it.
6. **A Codex fix does not skip review.** It still goes through CI, Claude review, and the GitHub
   Codex bot like any other code.

### Choosing a threshold

`--fix` defaults to P1 only, and **P1 is rarer than you'd expect**: Codex weighs reachability, so a
textbook shell-injection in code with no production callers comes back P2, not P1. Expect
`--fix` to often report "no findings at or above P1 — nothing to fix."

That is the intended conservative default. `--fix-threshold P2` fires far more often and is
reasonable when you are going to read the diff carefully anyway. Do not raise the default.

The reason `--fix` is narrow: the value of Codex here is that it is an *independent* check. If
Codex both finds and fixes, and nobody reads the diff, you have re-created the exact self-review
bias this skill exists to correct — just pointed at the other model.

## Accounts / subscriptions

Codex auth lives in `$CODEX_HOME/auth.json`, so a second subscription is just a second
`CODEX_HOME`. Two roots exist, set up by `bin/setup-symlinks.sh`:

| root | account | interactive alias |
| --- | --- | --- |
| `~/.codex` | personal ChatGPT | `cop` / `copf` |
| `~/.codex-work` | Asymmetric work seat | `cow` / `cowf` |

`config.toml`, `AGENTS.md` and `skills/` are symlinked into both from dotfiles, so the two roots
differ only in `auth.json` and session history.

**This script inherits `CODEX_HOME` rather than defining its own variable.** If a repo exports
`CODEX_HOME` (direnv, `.envrc.local`), both interactive `codex` and this script use that seat —
an agent can never review on one account while the terminal beside it burns the other's quota.
`--account personal|work` overrides for one invocation. With nothing set, it falls back to
`~/.codex`.

If the resolved root has no `auth.json`, the script prints the exact login command and exits 3.

**Quota is a real constraint.** `auth_mode` is `chatgpt`, not an API key, so runs draw on a plan
usage window rather than per-token billing. On the personal root that window is the one Robbie
uses himself. Don't run this on trivial diffs, and don't fan it out across many checkouts at once.

## Failure handling — fail-warn, never fail-stop

Exit 4 means the review did not run (timeout, rate limit, Codex down). **That is not a blocker.**
Proceed on your own judgement or ask for Robbie's.

Exit 3 means auth/setup is wrong — fix it, the message says how. Exit 2 is a bad argument.

## Notes

- The script uses `command codex` deliberately: Robbie's shell aliases `codex` to
  `codex --yolo --search`, which disables the sandbox. Never invoke bare `codex` from automation.
- The sandbox is pinned to `workspace-write`, not `read-only`. Under `read-only` Python's
  `tempfile` cannot create a scratch dir, so the repo's own suite fails spuriously and Codex
  reports sandbox noise as evidence. Review mode still writes nothing to the tree (verified).
- Review takes ~40–70s on a mid-size diff, but a diff spanning several bricks of a
  comment-dense repo runs far longer — at `xhigh` reasoning most of the wall clock is context
  gathering, not judging. Hence the 1200s default: a watchdog kill lands mid-read and writes no
  `review.md` at all, so a timeout costs the whole review rather than truncating it.
