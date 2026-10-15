---
name: rt
description:
  Retire. End this session by requesting the reaper kill it. Only when Robbie runs /rt.
disable-model-invocation: true
argument-hint: "[reason]"
---

# Retire

Robbie wants this session gone. Wrap up in one short final message, then make this the last tool
call of the turn:

```bash
agent-reaper request --reason "<why you're done>"
```

Use Robbie's argument as the reason if he gave one.

Don't retire if work is unfinished, failed, or blocked on Robbie: say so and stay alive instead.
