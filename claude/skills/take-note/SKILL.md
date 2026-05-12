---
name: take-note
description: Use when creating or updating repo notes, .claude/notes files, or CLAUDE.md note indexes.
---
# Take Note
Store durable repo notes in `.claude/notes/*.md`; local-only notes go in `.claude/notes/local/*.md`. Use kebab-case filenames. Every note must be indexed under `## Notes` in nearest `CLAUDE.md`:
`- [Title - when to read this](.claude/notes/file.md) - short gloss`
Behavioral one-liners go directly in `CLAUDE.md`, not notes.
