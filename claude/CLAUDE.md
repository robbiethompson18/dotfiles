# Claude Code Instructions

## Git workflow

- Do not commit or push changes unless explicitly asked.
- If I tell you to commit and/or push something, that applies only to the
current changes. Please do not commit and push later on without permission.

## Development server

- The user will typically use `prd` to start the dev server. 
- This runs `pnpm run dev` and logs output to `/tmp/dev-output.log`.
- You should check these logs when you're helping the use debug.
- You can read `/tmp/dev-output.log` to check dev server output, errors, or build status.
