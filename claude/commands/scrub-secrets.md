# Scrub Secrets from Shell History

Scan zsh history for API keys, tokens, and passwords, then remove them.

## Steps

1. **Scan** `~/.zsh_history` for patterns like:
   - `OP_SERVICE_ACCOUNT_TOKEN=ops_...`
   - `sk-[a-zA-Z0-9]{20,}` (OpenAI keys)
   - `xox[bpas]-...` (Slack tokens)
   - `ghp_...`, `gho_...` (GitHub tokens)
   - `ANTHROPIC_API_KEY=...`, `OPENAI_API_KEY=...`
   - `sessionToken=...`
   - `"password": "..."` patterns
   - `Bearer [a-zA-Z0-9_-]{20,}`
   - Any other obvious secrets

2. **Report** how many lines contain potential secrets (show truncated samples)

3. **If secrets found**, ask user for confirmation, then:
   - Backup to `~/.zsh_history_backup_$(date +%s)`
   - Filter out lines with secrets
   - Replace `~/.zsh_history` with cleaned version

4. **Remind** user to rotate any exposed credentials

## Notes

- Use `HIST_IGNORE_SPACE` — prefix sensitive commands with a space to keep them out of history.
- After cleaning, the backup still contains secrets — remind user to delete it after verifying.
