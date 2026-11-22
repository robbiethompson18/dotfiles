---
name: todo-imessages
description:
  Triage the notes Robbie texts himself on iMessage since his last "done" marker. Links go into the
  Reading List tab of his Stack doc, todos get listed in chat and worked through one at a time. Use
  when Robbie runs /todo-imessages or asks to go through his messages or notes to himself.
---

# todo-imessages

Robbie texts himself notes. When he has processed everything, he sends himself a marker like
`—————done—————`. This skill handles everything after the most recent marker.

This repo is public. Nothing from the notes goes into a file here.

## 1. Read the notes

```bash
python3 .claude/skills/todo-imessages/self_messages.py
```

It prints the last marker and every note since, oldest first. `--markers` lists recent markers,
`--since "YYYY-MM-DD"` overrides the cutoff. Tell Robbie the marker date before anything else.

What the script already handles, so you don't redo it:

- `message.text` is NULL on recent macOS. The text is in `attributedBody`, which it decodes.
- There are two self-chats, one per handle (phone number, Apple ID email). It reads both and finds
  them from `destination_caller_id`, so no handle is hardcoded.
- Each note is stored twice (sent and received copy). It drops the second.
- iOS turns `--` into an em dash, so markers are matched on any dash type around the word "done".

`ATTACHMENT:` lines are real files (screenshots, PDFs). Read the images; they are often the note.

A long URL is sometimes split across two messages sent in the same second (the second starts
mid-token, e.g. with `.eyJ`). Treat the pair as one link.

## 2. Sort each note into one bucket

- **Reading**: articles, papers, videos, podcasts, tweets, books, and posts named without a link
  ("X post LW"). These go in the doc (step 3).
- **Todo**: anything with an action. Errands, people to contact, things to buy, book or apply for
  (application forms and residency pages are todos, not reading), things to look into.
- **Everything else**: blog post ideas, research ideas, workout logs, journal entries, drafts of
  texts to other people, links to his own docs, chats and repos. List these under their own
  headings. Don't file them anywhere unless he asks; the Stack doc has a Blog ideas tab if he does.

If a note fits two buckets (a contest announcement he probably wants to enter), add the link to the
doc and also list the todo. If you can't tell what a note means, quote it and ask.

## 3. Add reading to the doc

The doc URL and tab IDs are in `~/.claude/docs/stack-doc.md` (private repo). Load the
`google-workspace` skill before the first Docs call.

- Dedupe against every tab of the doc first, not only Reading List. He often files things by hand
  before running this. Compare YouTube links by video id and other links without the query string.
- Add one new section directly above the newest date header (below the `Pods:` block). The header
  is today's date as `M/D/YY`, then one bullet per item in the order he sent them, then a blank
  paragraph.
- Each bullet is the bare URL, set as a link (`updateTextStyle` with `fields: "link"`; the API does
  not auto-link). Strip tracking and gift-token query strings; keep ones that carry meaning
  (`?v=`, `?commentId=`).
- Add a short plain gloss after the URL only where the URL says nothing: YouTube
  (`https://www.youtube.com/oembed?url=<url>&format=json` gives the title), arXiv ids, tweets if you
  can get the text. Fix obvious typos in titles he typed.
- One `update_doc` batch, guarded with `requiredRevisionId`, `tabId` on every range. Read the doc
  again afterwards and check the bullet and link counts.

## 4. Report

In chat, in this order: the marker date, how many links went into the doc (and which you skipped
as duplicates), a numbered todo list with the date of each note, then the other buckets. Group
todos that belong together. Then go through the todos with him one at a time.

## 5. Mark done

When Robbie says the batch is handled, ask, then send the next marker:

```bash
python3 .claude/skills/todo-imessages/self_messages.py --mark-done
```

It sends `—————done as of M/D/YY—————` to the self-chat through Messages. If macOS blocks the
automation, ask Robbie to send the marker himself. Don't send it while todos are still open: the
marker is the only record of what has been processed.
