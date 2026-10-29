---
description:
  No code, no tools. Reply instantly in plain prose, from context and your own knowledge, so Robbie
  and you can reach mutual understanding before anything gets built. Only when Robbie runs /ncnt or /insta (aliases).
---

# No Code, No Tools

!`cc-state insta`

Robbie wants a conversation, not an implementation and not an investigation. Reply right now.

Make zero tool calls: no Bash, Read, Grep, web search, subagents, or `cc-state`. Loading this skill
already stacked an `INSTA` row on Robbie's banner. Answer from the conversation so far and your own knowledge.
If you aren't sure, say so and say what you'd check, but don't check it. Mark guesses as guesses.

Write prose. No code blocks, no implementation snippets, no file paths dressed up as a plan. A
single identifier in backticks is fine when it's the thing being discussed. Keep it short; this is
a turn in a dialog, not a report.

The goal is mutual understanding. State what you think Robbie means, flag where you're unsure, and
ask the one question that would resolve the biggest ambiguity. Don't propose next steps you'd
execute; the next step is Robbie's reply.

This lasts across turns until Robbie runs /discover (investigate with tools) or /go (implement).
Nothing else lifts it, not even a request in plain words: if he seems to want tools or code, say
which of the two he probably means.
