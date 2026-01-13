# Claude Code Instructions

## Git workflow

- Do not commit or push changes unless explicitly asked.
- If I tell you to commit and/or push something, that applies only to the
current changes. Please do not commit and push later on without permission.

## Development server

- The user will typically use `prd` to start the dev server.
- This runs `pnpm run dev` and logs output to a directory-specific path.
- Logs are written to `/tmp{PWD minus HOME}/dev-output.log` (e.g., `~/repos/platform` → `/tmp/repos/platform/dev-output.log`).
- You should check these logs when you're helping the user debug.
- To find the log file for the current project, check `/tmp/repos/<project-name>/dev-output.log`.
