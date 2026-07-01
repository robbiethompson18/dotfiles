---
name: address-note
description:
  Find a note Robbie left inline in a file (tagged with a short id like `claude5` / `@claude5`) and
  do what it asks, then mark it done. Use when Robbie runs `/address-note <id>` or tells you to
  address/handle a specific tagged note.
---

# Address Note

Robbie leaves inline notes for you in files, each tagged with a short id (e.g. `@claude5`,
`claude5`, `[claude5]`, or inside an HTML comment). When he invokes this skill he names one id —
find that note, do exactly what it asks, mark it done, and report.

## Steps

1. **Get the id.** It's the skill argument (e.g. `claude5`). If none was given, ask which note —
   don't guess.

2. **Find the note.** Grep the working tree for the id (skip `.git/`, `node_modules/`, and
   build-output dirs). Match any form: `@claude5`, `claude5:`, `[claude5]`, `<!-- claude5 … -->`,
   etc.
   - No match → say so and stop.
   - Several matches → pick the one that's clearly the note/instruction; if still ambiguous, show
     them and ask which.

3. **Read it in context.** The instruction may be the rest of that line, the sentence / bullet /
   block around the marker, or a nearby comment. Read enough of the file (and anything it points to,
   e.g. a research doc) to know exactly what it wants and where the change belongs.

4. **Do exactly what the note asks — and only that note.** Don't sweep up other `@claude` notes
   nearby (each is its own request). Follow the repo's `CLAUDE.md` conventions — e.g. for the blog:
   fill in research / numbers but don't rewrite prose or fix typos unless the note says so; one
   writer at a time on a file Robbie is actively editing. If the note is ambiguous, or acting on it
   would be irreversible or outward-facing, ask before proceeding.

5. **Mark it done.** Leave a trace in Robbie's comment style rather than silently deleting the
   marker — e.g. replace `@claude5` with `@robbie done`, or append `<!-- @robbie done (claude5) -->`
   in rendered markdown so it never shows on the page. If the note was a stub to fill, the filled
   content plus that marker is the completion.

6. **Report.** One line: what the note asked, what you did, the file/line — plus anything you're
   leaving for Robbie to decide.
