#!/usr/bin/env bash
# Run an OpenAI Codex review of the current change, locally, on Robbie's Codex
# subscription. Codex is a *different model lineage* than Claude, so it fails
# differently — that uncorrelated blind spot is the whole point.
#
# Text-only by default. `--fix` is opt-in and scoped to P1 findings.
set -uo pipefail

BASE=""; COMMIT=""; UNCOMMITTED=""; ASK=""; FIX=""
THRESHOLD=P1
ACCOUNT="${CODEX_ACCOUNT:-personal}"
TIMEOUT=420
MODEL=""

while [ $# -gt 0 ]; do
  case "$1" in
    --base)        BASE="$2"; shift 2 ;;
    --commit)      COMMIT="$2"; shift 2 ;;
    --uncommitted) UNCOMMITTED=1; shift ;;
    --ask)         ASK="$2"; shift 2 ;;
    --fix)         FIX=1; shift ;;
    --fix-threshold) THRESHOLD="$2"; shift 2 ;;
    --account)     ACCOUNT="$2"; shift 2 ;;
    --timeout)     TIMEOUT="$2"; shift 2 ;;
    --model)       MODEL="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# --- account selection -------------------------------------------------------
# Auth lives in $CODEX_HOME/auth.json, so a second subscription is just a second
# CODEX_HOME. Set CODEX_ACCOUNT=work in a work repo's .envrc.local to flip the
# default without touching this script.
case "$ACCOUNT" in
  personal) export CODEX_HOME="$HOME/.codex" ;;
  work)     export CODEX_HOME="$HOME/.codex-work" ;;
  *) echo "unknown --account: $ACCOUNT (want: personal|work)" >&2; exit 2 ;;
esac

if [ ! -f "$CODEX_HOME/auth.json" ]; then
  echo "codex-review: no Codex auth at $CODEX_HOME/auth.json (--account $ACCOUNT)." >&2
  echo "  Set it up with:  CODEX_HOME=$CODEX_HOME codex login" >&2
  exit 3
fi

ROOT=$(git rev-parse --show-toplevel) || exit 3
OUT="$ROOT/.git/codex-review"          # inside .git — never committed, per-checkout
mkdir -p "$OUT"

# --- run codex under a watchdog (macOS has no coreutils `timeout`) -----------
# `command` bypasses Robbie's `codex` alias, which carries --yolo.
run_codex() {
  command codex "$@" > "$OUT/raw.log" 2>&1 &
  local pid=$!
  ( sleep "$TIMEOUT"; kill -TERM $pid 2>/dev/null; sleep 5; kill -KILL $pid 2>/dev/null ) &
  local dog=$!
  wait $pid; local rc=$?
  kill $dog 2>/dev/null
  return $rc
}

# workspace-write, not read-only: under read-only, Python's tempfile cannot
# create a scratch dir, so the repo's own test suite fails spuriously and Codex
# reports sandbox noise as if it were evidence. Review itself writes nothing.
COMMON=(-c sandbox_mode="workspace-write")
[ -n "$MODEL" ] && COMMON+=(-m "$MODEL")

# --- consult mode ------------------------------------------------------------
if [ -n "$ASK" ]; then
  run_codex exec "${COMMON[@]}" -o "$OUT/answer.md" "$ASK"
  rc=$?
  if [ $rc -ne 0 ]; then
    echo "codex-review: consult failed (exit $rc) — see $OUT/raw.log" >&2
    exit 4
  fi
  cat "$OUT/answer.md"; echo; echo "(transcript: $OUT/raw.log)"
  exit 0
fi

# --- review mode -------------------------------------------------------------
SCOPE=(--base "${BASE:-main}")
[ -n "$COMMIT" ]      && SCOPE=(--commit "$COMMIT")
[ -n "$UNCOMMITTED" ] && SCOPE=(--uncommitted)

run_codex exec review "${SCOPE[@]}" "${COMMON[@]}" -o "$OUT/review.md"
rc=$?
if [ $rc -ne 0 ] || [ ! -s "$OUT/review.md" ]; then
  # Fail-warn, never fail-stop. A second opinion is a luxury; the day's work isn't.
  echo "codex-review: review unavailable (exit $rc) — see $OUT/raw.log" >&2
  echo "Proceed on your own judgement and say in the PR that the Codex pass did not run." >&2
  exit 4
fi

cat "$OUT/review.md"
echo
echo "---"
echo "review:  $OUT/review.md"
echo "transcript: $OUT/raw.log"

[ -z "$FIX" ] && exit 0

# --- fix mode (opt-in, P1 only) ---------------------------------------------
case "$THRESHOLD" in
  P1) PAT='^\s*-\s*\[P1\]' ;;
  P2) PAT='^\s*-\s*\[P[12]\]' ;;
  *) echo "unknown --fix-threshold: $THRESHOLD (want: P1|P2)" >&2; exit 2 ;;
esac
FINDINGS=$(grep -E "$PAT" "$OUT/review.md")
if [ -z "$FINDINGS" ]; then
  echo; echo "codex-review: no findings at or above $THRESHOLD — nothing to fix."
  exit 0
fi

# Snapshot the whole worktree — tracked, staged, dirty and untracked alike — as a
# git tree object, so `git diff $PRE $POST` later isolates exactly what Codex
# wrote. The main agent reviews that diff; it does not inherit the change unseen.
#
# Built in a side index via GIT_INDEX_FILE, so the real index is never touched
# and the user's staged state survives. `git stash create` cannot do this: it
# skips untracked files, and it hard-errors on intent-to-add entries
# ("Entry ... not uptodate. Cannot merge"), which is what `git add -N` leaves.
snapshot_tree() {
  ( export GIT_INDEX_FILE="$OUT/snap.index"
    rm -f "$GIT_INDEX_FILE"
    git read-tree HEAD && git add -A && git write-tree )
}

PRE=$(snapshot_tree)
if [ -z "$PRE" ]; then
  echo "codex-review: could not snapshot the worktree; refusing to let Codex write." >&2
  exit 4
fi
echo "$PRE" > "$OUT/pre-fix-tree"

echo; echo "codex-review: applying fixes at threshold $THRESHOLD (pre-fix snapshot $PRE)"
run_codex exec "${COMMON[@]}" -o "$OUT/fix.md" "$(cat <<PROMPT
Fix ONLY the findings listed below, in this repository.

Rules:
- Fix nothing that is not on this list. Do not refactor, rename, reformat or "clean up"
  anything the P1 fix does not strictly require.
- Add or update one test per fix that fails without the change.
- If a P1 needs a design decision rather than a mechanical fix, leave the code
  alone and say why. Do not guess.
- Do not commit, stage, push, or touch git history. Leave changes in the tree.

$FINDINGS
PROMPT
)"
rc=$?
POST=$(snapshot_tree)
git diff "$PRE" "$POST" > "$OUT/fix.diff"
git diff --diff-filter=A --name-only "$PRE" "$POST" > "$OUT/fix.new-files"

report() {
  echo "---"
  echo "WHAT CODEX WROTE  ($(git diff --shortstat "$PRE" "$POST" | sed 's/^ *//'))"
  git diff --stat "$PRE" "$POST" | sed 's/^/  /'
  echo "  full diff: $OUT/fix.diff"
  echo "REVERT"
  echo "  git checkout $PRE -- ."
  [ -s "$OUT/fix.new-files" ] && echo "  xargs rm -f < $OUT/fix.new-files   # checkout restores content, it does not delete new files"
}

if [ $rc -ne 0 ]; then
  echo "codex-review: fix pass failed (exit $rc). Partial changes below." >&2
  report
  exit 4
fi

cat "$OUT/fix.md"
echo
report
