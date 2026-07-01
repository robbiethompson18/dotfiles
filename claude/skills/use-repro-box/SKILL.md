---
name: use-repro-box
description:
  SSH into the AWS dev box `oc-dev-1` to run a real OpenClaw gateway. Use for
  agent/subagent/channel/compaction flows that unit tests can't exercise.
---

`oc-dev-1` (`i-00c7aaaab00deacb3`, AWS t4g.medium): `ssh oc-dev-1`. Has `~/openclaw` (fork +
`upstream` remote), `~/openclaw-upgrades`, `~/.openclaw/.env` with OpenRouter key. Onboarded.

Use: `git -C ~/openclaw checkout <ref>`, run `gateway run` in background, drive via
`node openclaw.mjs gateway call agent --params '{sessionKey,message,idempotencyKey,deliver:false}'`.
