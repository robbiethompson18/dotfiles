---
name: dl
description:
  Deeplink. Give Robbie the full local path to a file so he can click it open in his editor. Only
  when Robbie runs /dl.
disable-model-invocation: true
argument-hint: "[file or description]"
---

# Deeplink

Robbie wants a link to a file. A deeplink is the full absolute local path, not a URL and not a
repo-relative path:

`/Users/robbie/repos/dotfiles/claude/CLAUDE.md`

Which file:

- If he named or described one, find it (search if you have to) and confirm it exists.
- If not, use the file this conversation is about: the one you just wrote, edited, or mentioned.
- If several fit, list each path on its own line.

Append `:<line>` when a specific spot matters (`/Users/robbie/repos/x/foo.py:42`). Reply with the
path(s) in backticks and nothing else unless something was ambiguous.
