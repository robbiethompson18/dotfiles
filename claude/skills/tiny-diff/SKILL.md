---
name: tiny-diff
description: Browser diff viewer with per-line annotations. Use to surface a gnarly bit Robbie should look at, or when he says "show me with tiny-diff".
---

# tiny-diff

## When to use

- After a non-trivial change where the diff alone doesn't tell the story.
- To point at a specific subtle bit (race, invariant, workaround) instead of narrating in chat.
- Robbie says "show me with tiny-diff" or runs `/tiny-diff`.

## When NOT

- Trivial changes; chat is enough.
- Pure new files (nothing to compare).
- When Robbie's in flow and a browser pop is friction.

## Spec

```bash
cd $repo && echo '<JSON>' | tiny-diff
```

```json
{
  "base": "main",
  "files": [{
    "path": "src/foo.ts",
    "note": "optional file-level overview",
    "comments": [
      { "line": 42, "text": "..." },
      { "line": [50, 55], "text": "..." }
    ]
  }]
}
```

For committed work: `"HEAD~1"`, `"<sha>^"`, or `"origin/main"` as base.

## Comment hygiene

- ≤ 1–2 per file. Over-commenting is the failure mode.
- Earn the comment: must say something the diff doesn't.
- "Adds X" → drop. "Defends against PID reuse" → keep.

## Orphans

A comment on a line not in any displayed hunk goes to an orphan banner. Use `"show": "all"` or `"extra_ranges": [[N, N]]` to force unchanged lines into view.
