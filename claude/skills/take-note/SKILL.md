---
name: take-note
description:
  Use when creating or updating repo docs/notes in docs/, or the CLAUDE.md `## Docs` index.
---

# Take Note

Store durable repo docs in `docs/*.md` (flat by default; topic subfolders like `docs/runbooks/` only
once several of one kind exist); local-only docs go in `docs/local/*.md` (gitignored). If `docs/` is
a published site (`docs.json`, `mkdocs.yml`), check it won't publish the file. Use kebab-case
filenames. Every doc must be indexed under `## Docs` in nearest `CLAUDE.md`:
`- [Title - when to read this](docs/file.md) - short gloss` Behavioral one-liners go directly in
`CLAUDE.md`, not docs.
