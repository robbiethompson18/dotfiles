---
name: scrub-secrets
description: Scan zsh history for API keys, tokens, passwords, and other secrets, then remove them after user confirmation.
---

# Scrub Secrets from Shell History

Scan zsh history for API keys, tokens, and passwords, then remove them.

## Steps

1. Scan `~/.zsh_history` for patterns like:
   - `OP_SERVICE_ACCOUNT_TOKEN=ops_...`
   - `sk-[a-zA-Z0-9]{20,}` for OpenAI keys.
   - `xox[bpas]-...` for Slack tokens.
   - `ghp_...`, `gho_...` for GitHub tokens.
   - `ANTHROPIC_API_KEY=...`, `OPENAI_API_KEY=...`
   - `sessionToken=...`
   - `"password": "..."`
   - `Bearer [a-zA-Z0-9_-]{20,}`
   - Any other obvious secrets.

2. Report how many lines contain potential secrets. Show truncated samples only.

3. If secrets are found, ask the user for confirmation, then:
   - Back up to `~/.zsh_history_backup_$(date +%s)`.
   - Filter out lines with secrets.
   - Replace `~/.zsh_history` with the cleaned version.

4. Remind the user to rotate any exposed credentials.

## Notes

- Use `HIST_IGNORE_SPACE`: prefix sensitive commands with a space to keep them out of history.
- After cleaning, the backup still contains secrets. Remind the user to delete it after verifying.
