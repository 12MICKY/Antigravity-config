---
name: pteachlab-server
description: "pteachlab.com app server at 10.33.1.33 — Next.js+Postgres, login/env setup"
metadata: 
  node_type: memory
  type: project
  originSessionId: edd2c70c-c44a-41c6-8988-e2692d2ba920
---

**Server `10.33.1.33`** (user `pteachlab`, SSH pw `200152`, **sudo pw `Yaimakmak1234`** — different from SSH). Hosts **pteachlab.com** (an education platform, sibling of genius-lab).

- **Web app**: Next.js 16, Docker container `pteach-lab-web`. Uses **`network_mode: host`** (set 2026-06-02) so it reaches the host Postgres at `127.0.0.1:5432` (matches pg_hba `127.0.0.1/32` rule); binds host `:3000`. Env file `.env.production`.
- **Deployment source = `~/genius-lab`** (GitHub `LordShangbin/genius-lab-nextjs2`, private — auth via gh account `12MICKY` / PAT; token scrubbed from remote so `git pull` needs auth again). Image `genius-lab-web`, container `pteach-lab-web`. **Migrated 2026-06-02** from the old local `~/pteach-lab` copy (deleted, had no git remote). The repo has **NO deploy files** — `.env.production` + `docker-compose.yml` (network_mode host) + `Dockerfile` were copied in from backup `~/pteach-lab-backup-20260602-155001.tgz` (3.1M; keep it — those 3 files aren't in git). genius-lab schema is newer (has a `balance` column; `DB_RUN_MIGRATIONS=true` auto-added it to geniuslab_auth).
- **Login-by-name patch is NOT in the repo** — re-applied locally to `~/genius-lab/lib/server/auth-store.ts` (authenticateUser: `WHERE iduser=$1 OR lower(name)=lower($2) OR lower(nickname)=lower($2)` + `rows.find(verifyPassword)`). A fresh `git pull`/re-clone will drop it — re-apply. Verified 2026-06-02: ADMIN + name login + public https://pteachlab.com all 200.
- Old `~/pteach-lab` and `~/app` both deleted. Old `pteach-lab-web` image may still exist (prunable).
- **DB**: **local Postgres 16 on the host** (`/etc/postgresql/16/main`). Auth DB = **`geniuslab_auth`** (NOT pteach_lab_auth — that name doesn't exist), role **`geniuslab_app`** pw reset 2026-06-02 to `Yaimakmak1234`. Tables: users/sessions/session_tokens/login_attempts (scrypt password_hash, len 161). Also DB `pteach_moodle` (Moodle, role pteach_moodle_app). pg_hba allows geniuslab_app→geniuslab_auth from `10.33.1.0/24`,`127.0.0.1/32` (+ `172.17.0.0/16` was NOT added — host networking avoids needing it).
- **Users**: `ADMIN` (is_admin, pw `!cVz14ee3gQY`), `GL0007`=thiraphat, `GL0006`=Puripat (GL* passwords untouched).
- **Served via cloudflared** (`/etc/cloudflared/config.yml`, systemd, separate from the personal-infra tunnel): `pteachlab.com` + `www.pteachlab.com` → `:3000`; `moodle.pteachlab.com` → `:8081`.
- **Login-broke gotcha (fixed 2026-06-02):** `.env.production` was 0 bytes → container had no `DATABASE_URL` → all logins failed. Fix = populate env: `DATABASE_URL=postgresql://geniuslab_app:Yaimakmak1234@127.0.0.1:5432/geniuslab_auth`, `APP_ORIGIN=https://pteachlab.com`, **`ALLOWED_ORIGINS=https://www.pteachlab.com`** (api-security 403s any Origin not in APP_ORIGIN/ALLOWED_ORIGINS — www was getting 403), `DB_RUN_MIGRATIONS=true` + `ADMIN_IDUSER=ADMIN`/`ADMIN_PASSWORD` (admin seed lives INSIDE the migration block in `lib/server/auth-store.ts` — runs lazily on first DB request, upserts ADMIN via ON CONFLICT; migrations are idempotent). Then `sudo docker compose up -d --force-recreate`.
- **Lockout**: 5 failed logins → `login_attempts.locked_until` set (15 min), API returns 423. Clear via `delete from login_attempts where identifier='<IDUSER-UPPER>';` (identifier is uppercased iduser).
- **Login-by-name (added 2026-06-02):** `authenticateUser` in `lib/server/auth-store.ts` now matches `iduser = $1 OR lower(name)=lower($2) OR lower(nickname)=lower($2)` and picks the candidate whose password verifies (`result.rows.find(verifyPassword)`) — so iduser/name/nickname all work, case-insensitive, and shared names are disambiguated by password. Code change → must `docker compose up -d --build --force-recreate` (Next standalone image). .bak of auth-store.ts kept.

Related: [[project-overview]] [[infra-servers]]
