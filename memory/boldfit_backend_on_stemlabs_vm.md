---
name: boldfit-backend-on-stemlabs-vm
description: "BoldFit backend API deployed on StemlabS VM (165.101.64.38:2222), Postgres auth DB, demo user, SSH tunnel for client access"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7b2e119c-62f2-485c-9cf1-3ea56030eaa4
---

BoldFit ecosystem auth/data lives on the **StemlabS VM** ([[stemlabs_vps_vm]] / [[vm102_stemlabs_postgres]], public 165.101.64.38 SSH :2222, login `boldfit` / `3TT8zj!8dO`, has sudo).

- **Postgres 14**, localhost:5432 only. `boldfit` DB owned by role `boldfit`. pg_hba uses **PAM** for TCP → backend connects with the **Linux password** (`3TT8zj!8dO`) as `BOLDFIT_DB_PASSWORD`, `sslmode=disable`. (Role-level `ALTER ROLE ... PASSWORD` does NOT work for TCP auth here — PAM overrides.)
- Schema (`users`, `workout`) created by the backend's `Database.initialize()` on startup. Demo account: **demo / boldfit123** (created via `/auth/register`, never hand-insert hashes over SSH — `$` in pbkdf2 hash gets shell-expanded and corrupts it).
- **Backend** code at `/home/boldfit/backend` (rsynced from local `~/Projects/backend-boldfit-ecosystem`), venv, systemd unit **`boldfit-backend.service`** → uvicorn on `0.0.0.0:8001`. `.env` has DB creds + a random `BOLDFIT_SECRET`. Needed `apt install python3.10-venv` first.
- **Public URL: `https://boldfit-api.thiraphat.work`** → served by the **.34 K3s cloudflared** (tunnel `51f79d1f`, the personal `*.thiraphat.work` one — NOT a tunnel on the VM). Path: DNS→.34 cloudflared → ingress `http://10.33.1.34:18084` → **`.34` systemd `boldfit-tunnel.service`** (SSH `-L 10.33.1.34:18084 → VM 127.0.0.1:8001`) → VM backend. The ingress entry lives in ConfigMap `cloudflared-config` (ns apps); `.34`→VM SSH is key-auth as `boldfit` (.34's `~/.ssh/id_ed25519` added to VM authorized_keys).
- The old VM-hosted tunnel `boldfit-api` (id `2647bc0a…`, `cloudflared-boldfit.service`) was **removed** when the tunnel moved to .34 (backend + Postgres stay on the VM). To change the public route: edit ConfigMap `cloudflared-config` + `kubectl rollout restart deployment/cloudflared -n apps` on .34.
- Port 8001 is not directly public; raw access from a dev box: `ssh -N -L 8001:127.0.0.1:8001 -p 2222 boldfit@165.101.64.38`.

`skeletondetect-boldfit-ecosystem` `/detect` verifies these tokens via shared `BOLDFIT_SECRET` (SSO, no own user store). Flutter desktop client in `client_flutter/` logs in here. See [[project_overview]].

**Outage gotcha (2026-06-16, confirmed in code):** the ConfigMap `cloudflared-config` entry for `boldfit-api.thiraphat.work` → `http://10.33.1.34:18084` can go missing (e.g. wiped by an unrelated ConfigMap edit/apply) — when it's gone, the hostname falls through to the `*.thiraphat.work` wildcard → Traefik → **plain-text "404 page not found"** (Traefik's 404, not FastAPI's JSON 404 — that's the tell). Separately after a backend redeploy, the old uvicorn can be left orphaned holding port 8001 so the new systemd-managed `boldfit-backend.service` crash-loops on "address already in use" (`systemctl status` shows `activating`, not `active`) — kill the orphan PID (`ss -tlnp | grep 8001`) then `systemctl restart boldfit-backend.service`. And the .34→VM SSH tunnel (`boldfit-tunnel.service`) can go stale after the VM-side process restarts (systemd still shows `active` and `ss` shows it listening, but the forwarded channel is dead) — `systemctl restart boldfit-tunnel.service` on .34 fixes it. Check all three layers in order when `boldfit-api.thiraphat.work` is unreachable: ConfigMap ingress entry → tunnel service → backend service.
