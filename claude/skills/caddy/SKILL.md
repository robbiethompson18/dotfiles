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
- Reload after edits — **no sudo needed**: `caddy reload --config /opt/homebrew/etc/Caddyfile --address localhost:2019`.
  The `caddy` binary talks to Caddy's local admin API on `localhost:2019`, which is reachable by any
  local user even though the Caddy process itself runs as root (needed to bind `:80`). Prefer this
  over `sudo brew services restart caddy` — that needs an interactive password prompt Claude can't
  supply, and as of 2026-07 `brew services restart`/`list` errors out with a Homebrew Ruby bug
  (`undefined method 'stop_timeout'`) on this formula version regardless.
- The Caddy process launched via `caddy run` (no `--watch` flag) does **not** auto-reload on file
  changes. If you edit the Caddyfile and skip the reload step, new/changed hostnames get a
  `308 → https://` redirect to nowhere (Caddy's global auto-HTTPS catch-all for hosts it doesn't
  recognize on port 80) — it looks like an ".app-TLD" or cert problem but isn't; it's just a stale
  config. Always reload after editing.
- The browser hits `http://<app>.localhost/` (port 80, no port in URL) and Caddy forwards to
  `127.0.0.1:<app-port>`.

The `.localhost` TLD is RFC-reserved and resolves to `127.0.0.1` automatically — **no `/etc/hosts`
entry needed**. Browsers also treat `*.localhost` as a secure context, so HTTP works without
warnings.

`http://app.localhost/` is a landing page listing every app below with a live up/down check — see
"Landing page" section.

## Adding a new app

1. App listens on a free port (e.g. `8765`) bound to `127.0.0.1`.
2. Append a block to `/opt/homebrew/etc/Caddyfile`:
   ```
   http://myapp.localhost {
       reverse_proxy localhost:8765
   }
   ```
3. `caddy reload --config /opt/homebrew/etc/Caddyfile --address localhost:2019`
4. Visit `http://myapp.localhost/`.
5. Add it to both the port registry below AND the `APPS` array in
   `~/repos/dotfiles/caddy/app-localhost/index.html` so it shows up on `app.localhost`.

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
| 7100 | `inbox.localhost`                           | `~/repos/inbox`            |
| 7101 | `birds.localhost`                           | `~/repos/whimsy-projects/heard-today` |
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
| 8090 | `bloomy.localhost`                          | `~/repos/bloomy-light-mode`   |
| 8091 | `2.bloomy.localhost`                        | `~/repos/bloomy-light-mode-2` |
| 8092 | `3.bloomy.localhost`                        | `~/repos/bloomy-light-mode-3` |
| 8093 | `4.bloomy.localhost`                        | `~/repos/bloomy-light-mode-4` |
| 8094 | `5.bloomy.localhost`                        | `~/repos/bloomy-light-mode-5` |
| 8095 | `6.bloomy.localhost`                        | `~/repos/bloomy-light-mode-6` |
| 8096 | `7.bloomy.localhost`                        | `~/repos/bloomy-light-mode-7` |
| 8097 | `8.bloomy.localhost`                        | `~/repos/bloomy-light-mode-8` |
| 8098 | `9.bloomy.localhost`                        | `~/repos/bloomy-light-mode-9` |
| 54403 | `db.9.bloomy.localhost`                    | Supabase Studio, bloomy-light-mode-9 |

Bloomy uses `N.bloomy.localhost` rather than the `bloomy-N.localhost` shape the Sapient rows use.
That's deliberate: `localhost` is not in the public suffix list, so every checkout shares the
registrable domain `bloomy.localhost` and **one 1Password item covers all eight checkouts**.
`bloomy-2.localhost` would be its own registrable domain and would need its own item.

Bloomy's Vite config hardcodes `port: 8080` with `strictPort` off, so checkouts silently drift to
8081, 8082, … in start order — which would leave these hostnames pointing at whichever checkout
booted first. The fix is per-checkout `.dev-port` files (globally gitignored, containing just the
port number); `prd` reads that file and passes `--port N --strictPort` to Vite. A checkout without
`.dev-port` behaves exactly as before.

### Bloomy local Supabase stacks

`supabase/config.toml` is tracked and names the PRODUCTION project ref, so every checkout that ran
`supabase start` drove the SAME containers on the SAME default ports (54321–54324) — one shared
stack for all the checkouts, and no way to run two at once.

The fix is a per-checkout project under `.supabase-local/`, driven with the CLI's `--workdir` flag,
so nothing tracked has to change:

```bash
supabase --workdir .supabase-local start
```

Its `supabase/migrations` and `supabase/functions` are symlinks back to the real tracked
directories, so there is one copy of each on disk. Port block per checkout N is `54320 + (N-1)*10`,
which leaves checkout 1 on the stock ports:

| Checkout | project_id | API   | DB    | Studio |
| -------- | ---------- | ----- | ----- | ------ |
| (shared, legacy) | `tudrtkigpnmmccmudxwr` | 54321 | 54322 | 54323 |
| `bloomy-light-mode-9` | `bloomy9` | 54401 | 54402 | 54403 |

Point the app at it with a per-checkout `.env.local` (`VITE_SUPABASE_URL`,
`VITE_SUPABASE_PUBLISHABLE_KEY`) — **not** the repo's `.env`, which is a symlink to
`bloomy-light-mode-2/.env` and shared by every checkout.

Full write-up, including the edge-runtime/Deno setup, lives in that repo at
`.claude/notes/local-supabase-stack.md`.

Static apps served directly via Caddy's `file_server` (no port, no backend process):

| Hostname             | Source                                        |
| --------------------- | ---------------------------------------------- |
| `shire.localhost`     | `~/repos/whimsy-projects/neighborhood-map`     |
| `app.localhost`       | `~/repos/dotfiles/caddy/app-localhost` (landing page, see below) |

## Landing page

`app.localhost` lists every app in this registry as a clickable card, with a client-side reachability
ping (green dot = responded in the last 30s). It's a static file, hand-maintained — the `APPS` array
in `~/repos/dotfiles/caddy/app-localhost/index.html` needs a new entry whenever this registry gets
one. There's no way to auto-derive it from the Caddyfile without a backend, so keeping the two in
sync is on whoever adds the app (see step 5 above).

Sapient stack — web port is Caddy-routed (rows above); API and Postgres ports are internal-only.
Per-checkout ports live in each checkout's `.envrc.local`. Each checkout has its **own** Docker
Postgres container (`POSTGRES_PORT`, read by `compose.yaml` via `${POSTGRES_PORT:-5435}`) — this
used to be one container shared by every checkout on a hardcoded 5435, which silently went stale
(2026-07-27, see that repo's `CODE_SMELL.md`):

| Service                | sapient | sapient-2 | sapient-3 | sapient-4 | sapient-5 | sapient-6 | sapient-7 | sapient-8 |
| ---------------------- | ------- | --------- | --------- | --------- | --------- | --------- | --------- | --------- |
| Web (Vite)              | 8767    | 8770      | 8772      | 8774      | 8776      | 8778      | 8780      | 8782      |
| API (`API_PORT`)        | 8769    | 8771      | 8773      | 8775      | 8777      | 8779      | 8781      | 8783      |
| Postgres (`POSTGRES_PORT`) | 5435 | 5436      | 5437      | 5438      | 5439      | 5440      | 5441      | 5442      |

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
| 5435–5442 | Postgres, one per sapient checkout (see Sapient stack table above) |
| 18789 | OpenClaw gateway (bastion-forwarded)     |

**Rough convention** for picking a new port:

- One-off hobby web apps → `7XXX` (next free) or `8XXX` (next free).
- Platform-style stacks → claim the next column in the platform table.
- Avoid 3000–3019, 5173–5180, 5432–5442, 18789–18793.

## Troubleshooting

- **"This site can't be reached"** → Caddy isn't running. `sudo brew services start caddy`.
- **Hostname resolves but page is blank / 502** → the backend app isn't listening. Check the port
  directly with `curl localhost:PORT`.
- **Got the directory listing instead of the app** → app's `/` doesn't serve the entry HTML. Either
  add an `index.html` or special-case `/` in its router.
- **Lost track of what's listening** → `lsof -iTCP -sTCP:LISTEN | grep LISTEN`.
