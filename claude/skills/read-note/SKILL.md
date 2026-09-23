---
name: read-note
description:
  Use when reading repo docs/notes, finding relevant docs/ files, or checking the CLAUDE.md `## Docs`
  index.
---

# Read Note

Find the nearest `CLAUDE.md`, read its `## Docs` index, then open only docs relevant to the task.
Repo docs live in `docs/`; local-only docs in `docs/local/`. Older repos may still use a `## Notes`
index and `.claude/notes/` — read those the same way. If no index exists, mention that and inspect
`docs/` directly only when needed.
