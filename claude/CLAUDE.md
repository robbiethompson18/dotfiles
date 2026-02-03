# Claude Code Instructions

## Tool restrictions

- Never use `sed` for file editing. Always use the Edit tool instead.

## Git workflow

- Do not commit or push changes unless explicitly asked.
- If I tell you to commit and/or push something, that applies only to the
current changes. Please do not commit and push later on without permission.

## Development server

- The user will typically use `prd` to start the dev server.
- This runs `pnpm run dev` and logs output to a directory-specific path.
- Logs are written to `/tmp{PWD minus HOME}/dev-output.log` (e.g., `~/repos/platform` → `/tmp/repos/platform/dev-output.log`).
- These are **local dev server logs only**, not production logs. There is no access to production logs from here.
- You should check these logs when you're helping the user debug local dev issues.
- To find the log file for the current project, check `/tmp/repos/<project-name>/dev-output.log`.

## Log checking

- Never tell the user to check logs themselves (e.g., "run `fly logs`" or "check `cat /tmp/logs/x`").
- Always check logs yourself and report what you find, if checking logs is necessary for the task at hand.

## Sensitive commands

- `HIST_IGNORE_SPACE` is enabled: commands starting with a space are not saved to zsh history.
- When running commands with API keys, tokens, or passwords, **prefix with a space** to keep them out of history.
- Example: ` export API_KEY=sk-secret` (note leading space) — runs normally but isn't logged.

## Time Zone

Always display times in **California time (Pacific)**. Convert UTC timestamps before showing them.
- PST (Nov–Mar): UTC-8
- PDT (Mar–Nov): UTC-7

## Sensitive Things

Always ask the user before: 
* Using Pulumi
* Deploying to prod
* Resetting the DB or dropping tables
* Doing an ugly database migration
