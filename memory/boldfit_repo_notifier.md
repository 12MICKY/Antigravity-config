---
name: boldfit-repo-notifier
description: Discord bot on .34 that alerts on new commits/releases/PRs across the 8 Bold Fit GitHub repos
metadata: 
  node_type: memory
  type: project
  originSessionId: 01c34b6a-a684-4f46-89e7-52a5e7f123af
---

Bold Fit Repo Notifier — Discord notification bot. Source: `~/boldfit-repo-notifier` (notifier.py, Dockerfile, .env), GitHub: `12MICKY/boldfit-repo-notifier` (private; README has mermaid architecture + poll-cycle diagrams, deploy/ holds the K3s manifest copy). Runs as **K3s Deployment `boldfit-repo-notifier` in ns `apps`** on .34 (migrated off raw docker 2026-06-10). Image `10.33.1.34:5000/boldfit-repo-notifier:latest` (in-cluster registry), env from Secret `boldfit-repo-notifier-env`, state on PVC `boldfit-notify-data` (local-path). Manifest: `~/k3s-manifests/apps/boldfit-repo-notifier.yaml` (both laptop and .34).

- Polls GitHub API every 5 min (POLL_INTERVAL=300) for **new commits · releases · PRs (open/merge/close) · issues (open/close/reopen) · issue/PR comments**, posts color-coded Discord embeds via webhook (no emojis; commit author = GitHub login with git-name fallback). Commits watched on default branch + EXTRA_BRANCHES (currently `hirax`).
- Watches 7 boldfit-only repos (REPOS env, comma-sep): 12MICKY/{boldfit-mobile, bold-fit-ecosystem, skeletondetect-boldfit-ecosystem, boldfit-desktop-app, frontend-boldfit-ecosystem-, backend-boldfit-ecosystem, BOLD-FIT-APP-}. (Weight-Training-Club intentionally excluded — not boldfit.)
- To change REPOS/branches/interval: edit `.env` on .34, recreate Secret (`kubectl delete secret boldfit-repo-notifier-env -n apps` + `kubectl create secret generic ... --from-env-file=...`), then `kubectl rollout restart deploy/boldfit-repo-notifier -n apps`. Code change: rebuild+push image to 10.33.1.34:5000 then rollout restart.
- OPEN TODO: swap GITHUB_TOKEN to a fine-grained read-only PAT scoped to the 7 boldfit repos (current token is the full-scope personal one).
- First poll per repo initializes state silently (no backfill spam); only new items after init are announced.
- GITHUB_TOKEN = the `gh auth token` (account 12MICKY). DISCORD_WEBHOOK in .env (chmod 600).
- **Gotcha:** Discord/Cloudflare blocks urllib's default User-Agent with HTTP 403 "error code: 1010" — must send a custom User-Agent header on the webhook POST.
- Edit repos/interval in .env then `docker restart boldfit-repo-notifier`.

Related: [[boldfit_ecosystem_roadmap]] [[project_overview]]
