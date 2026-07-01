---
name: agentmail
description:
  Send and receive email through a dedicated AgentMail inbox. Usable by any AI agent, especially for
  testing.
---

# AgentMail

The email is:

```text
codex-robbie@agentmail.to
```

Use the bundled direct AgentMail CLI:

```bash
~/.codex/skills/agentmail/scripts/agentmail.py inbox
~/.codex/skills/agentmail/scripts/agentmail.py list 10
~/.codex/skills/agentmail/scripts/agentmail.py threads 10
~/.codex/skills/agentmail/scripts/agentmail.py read <message-id>
~/.codex/skills/agentmail/scripts/agentmail.py thread <thread-id>
~/.codex/skills/agentmail/scripts/agentmail.py send <to> <subject> <body>
~/.codex/skills/agentmail/scripts/agentmail.py reply <message-id> <body>
```

The script reads credentials from the skill-local `.env` file. Do not print or commit that file.

## Threading

Always use `reply` for follow-ups to an existing email conversation. Use `send` only for a new
recipient or a completely new subject.

Before replying:

1. Run `threads` to find the relevant thread.
2. Run `thread <thread-id>` to inspect the conversation.
3. Reply to the most recent relevant `message_id`.

For long or HTML bodies, pipe content through stdin:

```bash
cat /tmp/email.html | ~/.codex/skills/agentmail/scripts/agentmail.py send person@example.com "Subject" --html
```
