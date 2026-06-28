---
name: boldfit-ecosystem-roadmap
description: "BOLD FIT Ecosystem vision + planned-but-not-built backend features (QR check-in, gamification, leaderboard, station identity)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7b2e119c-62f2-485c-9cf1-3ea56030eaa4
---

**BOLD FIT Ecosystem** = active-health infrastructure for schools. The desktop app ([[boldfit-desktop-app]]) is the **kiosk embedded on each Exercise Station** (machine-side touch panel, 194×110mm, `BOLDFIT_KIOSK=1` fullscreen). Vision: turn school spaces into exercise stations; 3 parts = **Exercise Stations** (Pull-up/Push-up/Squat kiosks), **AI Motion Analysis** (MediaPipe form scoring), **Data & Gamification Engine** (frequency/progress + points). Sandbox: **Satit Chula (โรงเรียนสาธิตจุฬาฯ)**, 1-year data collection, scale via กรมพลศึกษา.

**Device split (decided):** kiosk = "do" (live camera count + form feedback + QR check-in + station identity + instant points + auto-logout, glanceable/shared). Mobile = "identity + track + motivate" (login/profile, scan QR to check in, personal dashboard/history, gamification/leaderboard, reminders). Backend = shared (auth, data, gamification, leaderboard, station registry, QR session linking).

**QR check-in login — BUILT + DEPLOYED + verified end-to-end (Jun 2026).** WhatsApp-Web style: kiosk shows QR → phone scans & approves → kiosk gets token. Backend (`backend-boldfit-ecosystem`, deployed on VM): `qr_session` table + `POST /auth/qr/start` (kiosk, 2-min single-use code+station), `POST /auth/qr/approve` (phone, auth), `GET /auth/qr/poll?code=` (kiosk → one-time access_token). Kiosk side (`boldfit-desktop-app`): "Check in with QR" on login → `QrCheckinScreen` (qr_flutter), station from `BOLDFIT_STATION` env. Phone side (`boldfit-mobile`): `mobile_scanner` reads `{code, api}` → approves with its token.

**Still planned — NOT built yet:**
- **Gamification**: points = pushups+situps+round(running); **streak** = consecutive active days; `GET /users/{id}/stats`.
- **Leaderboard**: `GET /leaderboard` (top users by points).
- **Station tag**: `station TEXT` column on `workout` + accept in WorkoutCreate; `BOLDFIT_STATION` env per kiosk.
- Later: form-quality/biomechanics score (have joint angles already), admin web dashboard for teachers/กรมพลศึกษา.

I half-wrote these in `backend-boldfit-ecosystem/app/database.py` then reverted on request — repo + VM are back to the clean current state (auth + /workouts + /dashboard + /running-series only). See [[boldfit-backend-on-stemlabs-vm]]. When asked to build: do it in one pass + deploy to the VM (rsync `/home/boldfit/backend` + `systemctl restart boldfit-backend`).
