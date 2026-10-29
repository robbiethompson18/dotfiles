---
name: discover
description:
  End /insta mode and investigate with tools. Research is allowed, changing code or files is not.
  Only when Robbie runs /discover.
argument-hint: "[what to figure out]"
---

# Discover

!`cc-state insta-off`

/insta is over and its banner row is gone. Go use tools to figure out what the conversation so far
left open, or what Robbie's argument asks.

Allowed: read-only investigation. Read files, grep, `git log`/`git show`/`git diff`, web search,
read-only CLI queries, Explore subagents.

Not allowed: creating, editing, or deleting files, or running anything that changes state. If the
answer is "this needs a code change", describe it and stop; /go is how Robbie asks for it.

Report what you found and run `cc-state results`.
