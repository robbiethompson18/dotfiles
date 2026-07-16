---
name: caddy
description:
  Robbie runs a local Caddy reverse proxy that maps `<app>.localhost` → some local port, and this
  skill also doubles as the port registry for his machine. Use this when adding a new local app,
  picking a port (check the registry to avoid collisions, then update it), designing URLs, or when
  seeing hardcoded `localhost:PORT` strings that should use the Caddy hostname.
---

# caddy

## The setup

Caddy runs as a launchd service (started via `sudo brew services start caddy`), listening on `:80`.
It reverse-proxies hostnames to ports.

- Caddyfile: `/opt/homebrew/etc/Caddyfile`
- Restart after edits: `sudo brew services restart caddy`
- The browser hits `http://<app>.localhost/` (port 80, no port in URL) and Caddy forwards to
  `127.0.0.1:<app-port>`.

The `.localhost` TLD is RFC-reserved and resolves to `127.0.0.1` automatically — **no `/etc/hosts`
entry needed**. Browsers also treat `*.localhost` as a secure context, so HTTP works without
warnings.

## Adding a new app

1. App listens on a free port (e.g. `8765`) bound to `127.0.0.1`.
2. Append a block to `/opt/homebrew/etc/Caddyfile`:
   ```
   http://myapp.localhost {
       reverse_proxy localhost:8765
   }
   ```
3. `sudo brew services restart caddy`
4. Visit `http://myapp.localhost/`.

## What "Caddy-aware" means for an app

An app behaves well under Caddy when:

- **It serves the user-facing entry point at `/`.** Not `/myapp.html`. If the underlying server is
  `python -m http.server`-style, name the entry file `index.html`.
- **User-facing URLs in the app's output use the Caddy hostname**, not `localhost:PORT`. CLI tools
  that print "open this URL" should print `http://myapp.localhost/...`.
- **Internal calls** (CLI → its own daemon, healthchecks, etc.) **stay on `127.0.0.1:PORT`**.
  Faster, doesn't depend on Caddy being up, no proxy hop. Don't route the app's own internal traffic
  through Caddy.

## Port registry

**Single source of truth for every port Robbie's machine reserves.** Before picking a port for a new
app, scan this list to avoid collisions. After picking one, **update this file**.

Caddy-routed apps (have a `*.localhost` hostname):

| Port | Hostname                                    | Source                     |
| ---- | ------------------------------------------- | -------------------------- |
| 6006 | `tblocal.localhost`                         | TensorBoard (local)        |
| 6007 | `tbvm.localhost`                            | TensorBoard (VM)           |
| 7000 | `robbiewmthompson.localhost`                | `~/repos/personal-website` |
| 7327 | `tinydiff.localhost`                        | `~/repos/tiny-diff`        |
| 8765 | `cognitive.localhost`                       | `~/repos/cognitive-tests`  |
| 8766 | `silkworm-aws-resource-dashboard.localhost` | `~/repos/silkworm`         |
| 8767 | `sapient.localhost`                         | `~/repos/sapient`          |
| 8768 | `silkworm-experiments.localhost`            | `~/repos/silkworm`         |
| 5173 | `silkworm-experiments-ui.localhost`         | `~/repos/silkworm`         |
| 8770 | `sapient-2.localhost`                       | `~/repos/sapient-2`        |
| 8772 | `sapient-3.localhost`                       | `~/repos/sapient-3`        |
| 8774 | `sapient-4.localhost`                       | `~/repos/sapient-4`        |
| 8776 | `sapient-5.localhost`                       | `~/repos/sapient-5`        |
| 8778 | `sapient-6.localhost`                       | `~/repos/sapient-6`        |
| 8780 | `sapient-7.localhost`                       | `~/repos/sapient-7`        |
| 8782 | `sapient-8.localhost`                       | `~/repos/sapient-8`        |

Sapient stack — web port is Caddy-routed (rows above); API port is internal-only. Per-checkout ports
live in each checkout's `.envrc.local`; all checkouts share the postgres on 5435:

| Service          | sapient | sapient-2 | sapient-3 | sapient-4 | sapient-5 | sapient-6 | sapient-7 | sapient-8 |
| ---------------- | ------- | --------- | --------- | --------- | --------- | --------- | --------- | --------- |
| Web (Vite)       | 8767    | 8770      | 8772      | 8774      | 8776      | 8778      | 8780      | 8782      |
| API (`API_PORT`) | 8769    | 8771      | 8773      | 8775      | 8777      | 8779      | 8781      | 8783      |

Platform stack — each clone of `~/repos/platform*` claims one slot in each row:

| Service         | platform | platform-2 | platform-frontend |
| --------------- | -------- | ---------- | ----------------- |
| API (`PORT`)    | 3000     | 3001       | 3002              |
| AgentDrive      | 3010     | 3011       | 3012              |
| Vite            | 5173     | 5175       | 5177              |
| Vite AgentDrive | (n/a)    | 5176       | 5178              |
| Vite Chrome ext | 5174     | 5179       | 5180              |
| OpenClaw local  | (n/a)    | 18791      | 18793             |

Other reservations:

| Port  | What                                     |
| ----- | ---------------------------------------- |
| 5432  | Postgres (local docker)                  |
| 5433  | Postgres (bastion-forwarded staging RDS) |
| 5434  | Postgres (bastion-forwarded prod RDS)    |
| 5435  | Postgres (secondary docker)              |
| 18789 | OpenClaw gateway (bastion-forwarded)     |

**Rough convention** for picking a new port:

- One-off hobby web apps → `7XXX` (next free) or `8XXX` (next free).
- Platform-style stacks → claim the next column in the platform table.
- Avoid 3000–3019, 5173–5180, 5432–5435, 18789–18793.

## Troubleshooting

- **"This site can't be reached"** → Caddy isn't running. `sudo brew services start caddy`.
- **Hostname resolves but page is blank / 502** → the backend app isn't listening. Check the port
  directly with `curl localhost:PORT`.
- **Got the directory listing instead of the app** → app's `/` doesn't serve the entry HTML. Either
  add an `index.html` or special-case `/` in its router.
- **Lost track of what's listening** → `lsof -iTCP -sTCP:LISTEN | grep LISTEN`.
