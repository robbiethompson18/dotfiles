---
name: kas
description:
  Robbie will invoke this skill when he wants you to ship immediately after finishing this feature,
  then kill your own Claude/Codex session after shipping succeeds. Follow repo-specific shipping convention.
  Only request retirement with `agent-reaper request --reason kas` after ship completes
  successfully; if ship fails or is blocked, stay alive and report the problem.
---
