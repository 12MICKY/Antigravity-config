---
name: genius-lab-on-vm120
description: "genius-lab-nextjs2 (pteach-lab Next.js app) deployed on VM 120 pteachlab, PM2 + local Postgres"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7afa5257-c5d0-4c5c-ac60-669a2c9c19a5
---

**`pteach-lab-nextjs2`** (GitHub `LordShangbin/pteach-lab-nextjs2` — RENAMED from `genius-lab-nextjs2`; app name `pteach-lab`, Next.js 16) deployed on [[vm120-pteachlab-node5]] (now 10.33.1.27).

- **Git + auto-deploy (set up 2026-06-06):** `/home/pteachlab/app` is now a **git clone** (was rsync-only before; `git init` in place, remote=SSH `git@github.com:LordShangbin/pteach-lab-nextjs2.git`, `core.sshCommand` uses `~/.ssh/id_ed25519`). Auth = **read-only deploy key** on the repo (key id 153690680, title "pteachlab-vm120") — registered via the LordShangbin admin token used in-memory only (NO token stored on the VM; 12MICKY is only a collaborator and can't manage keys, repo owner = LordShangbin). **Auto-deploy:** `/home/pteachlab/auto-deploy.sh` (700) via **cron `*/5 * * * *`** — fetches origin/main, on new commit: snapshot `.next`→`.next.prev`, `git reset --hard`, `npm ci` (only if package-lock changed), `npm run build`; **build-gated** (restarts PM2 only on build success; on failure restores `.next.prev` so the live app never breaks), then `pm2 restart pteach-lab` + health-check `/api/health`. Log `/home/pteachlab/auto-deploy.log`. Validated end-to-end 2026-06-06. To push server-side changes up: just `git commit` + push (needs a WRITE creds — deploy key is read-only; use a token). **NB the repo's own `scripts/server-auto-deploy.sh` is DOCKER-based (docker compose) and does NOT fit this PM2 VM — don't use it; the PM2 path is `scripts/deploy-remote.sh`.**
- **⚠️ VM now HAS internet again (2026-06-06)** — the captive-portal block is gone (github :443 = 200), so the VM can `git fetch`/`npm ci` directly. (Was blocked before per [[vm120-pteachlab-node5]].)
- **Build-break fix 2026-06-06:** commit 8c75f27 added an empty 0-byte `app/home/page.tsx` → `next build` type-check failed ("is not a module"). Removed it (commit 4c4b930) to unblock. `lib/shared/routes.ts` still has `home: "/home"` used by `components/layout/Navbar.tsx` (logo + nav link) → **`/home` currently 404s** until the real page is re-added. Deployed HEAD builds clean (BUILD_ID present).

- **Run:** PM2 app `pteach-lab` (`pm2 start npm -- start`), boot-persistent via systemd unit `pm2-pteachlab` (enabled). App dir `/home/pteachlab/app`. Serves **`http://10.33.1.27:3000`** (VM now on Chula LAN — reach directly on LAN or via VPN). Repo's own deploy = `scripts/deploy-server.sh` (rsync + PM2). output:standalone in next.config but repo intentionally uses `next start` (warning is benign).
- **DB:** local PostgreSQL 16 on the VM, db `pteachlab`, role `pteach` / pw `cf5b4650751ff6026f89d74bba96ef3d`, `DB_SSL_MODE=disable` (same-server). Schema auto-created by app on first run with `DB_RUN_MIGRATIONS=true` (now flipped to `false`). Tables: users, sessions, session_tokens, login_attempts.
- **Admin login:** iduser `admin` / pw `8SwavXWDaW4BGCfQ` (seeded from ADMIN_IDUSER/ADMIN_PASSWORD; stored user id shows `ADMIN`). Login at `/api/auth/login`.
- **env** in `/home/pteachlab/app/.env.local`: APP_ORIGIN, DATABASE_URL, DB_SSL_MODE, DB_RUN_MIGRATIONS, ADMIN_IDUSER, ADMIN_PASSWORD.
- **Public via Cloudflare Tunnel (2026-06-03):** `https://pteachlab.com` (+ www + app.pteachlab.com) → cloudflared on the VM itself → http://localhost:3000. `APP_ORIGIN=https://pteachlab.com`.
  - Dedicated tunnel **`pteachlab`** id `92d654eb-571e-475b-87b2-4aa72ec98d48` (separate from the personal K3s `ai-server` tunnel). Runs as systemd `cloudflared` on the VM, `protocol: http2` (forced — captive portal allows TCP 7844 to argotunnel edge but blocks apt; QUIC/udp not relied on). Config `/etc/cloudflared/config.yml`, creds `/etc/cloudflared/92d654eb….json`. Binary was scp'd from laptop (VM can't download).
  - **DNS take-over:** pteachlab.com + www were CNAME→old tunnel `1631fe42-3504-4dd0-9e07-200c4ab84aff.cfargotunnel.com` (the old pteachlab.com site at 10.33.1.33); repointed to the new tunnel. **Rollback** = PATCH those CNAMEs back to `1631fe42….cfargotunnel.com`. Pre-change DNS backup: `~/.cloudflared/cf-pteachlab-dns-backup-20260603.json`.
  - **cloudflared certs on laptop:** active `~/.cloudflared/cert.pem` = thiraphat.work (restored). pteachlab.com zone cert saved as `~/.cloudflared/cert-pteachlab-com.pem` (needed to manage the `pteachlab` tunnel/DNS later — `cloudflared --origincert` or swap it in). pteachlab.com is a **separate CF zone** (id 56da7468…) from thiraphat.work.
- **CSRF gotcha:** `lib/server/api-security.ts` rejects API POSTs (403) whose `Origin`/`Referer` ≠ `APP_ORIGIN`. Was the IP before; now `https://pteachlab.com`. Change `APP_ORIGIN` + `pm2 restart pteach-lab --update-env` if the public hostname changes.
- **Lockout gotcha:** repeated failed/cross-origin logins lock the admin → HTTP **423**. Clear with `sudo -u postgres psql -d pteachlab -c "DELETE FROM login_attempts;"`.
- Toolchain installed on VM: Node 22 (NodeSource), PM2 7, PostgreSQL 16, + 2G swapfile (added to avoid OOM during `next build` on the 2GB VM).
