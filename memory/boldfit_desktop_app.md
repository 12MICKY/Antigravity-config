---
name: boldfit-desktop-app
description: "Bold Fit Ecosystem Flutter Linux desktop app — installed location, in-app webcam exercise (HomeCourt-style), tunnel + camera engine"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7b2e119c-62f2-485c-9cf1-3ea56030eaa4
---

**Bold Fit** = Flutter Linux desktop app (GTK + C++ runner). Canonical repo: **`12MICKY/boldfit-desktop-app`** (`~/Projects/boldfit-desktop-app`) — Flutter app at root, pose engine in `engine/desktop_counter`, `install.sh` builds+installs as an Ubuntu app. (An earlier copy also lives in `skeletondetect-boldfit-ecosystem/client_flutter`; boldfit-desktop-app is the one to edit/build going forward.) App-id **`work.thiraphat.boldfit`** (changed from `...boldfitecosystem` to dodge stale GNOME name cache when renaming — bump the app-id + .desktop filename if the displayed name ever sticks). Login `demo`/`boldfit123` (see [[boldfit-backend-on-stemlabs-vm]]).

Installed on the laptop (Ubuntu desktop) as a real app:
- Bundle: `~/.local/lib/boldfit-skeleton/` (binary `boldfit_skeleton_client`), launcher symlink `~/.local/bin/boldfit-skeleton`.
- Menu entry: `~/.local/share/applications/work.thiraphat.boldfit.desktop`, icon `~/.local/share/icons/hicolor/512x512/apps/work.thiraphat.boldfit.png` (from logoboldfit.png). Reinstall after `flutter build linux --release` by re-copying the bundle.
- Rebuild→reinstall must also re-copy the python engine: `~/.local/lib/boldfit-skeleton/exercises/desktop_counter/` (+ `pose_landmarker_lite.task`). App finds it at `<exeDir>/exercises` (or `BOLDFIT_EXERCISES_DIR`).

UI is **English-only**. Home opens straight to the exercise programs (the image-detect tab was removed). Push-up / Squat buttons → in-app live webcam with skeleton overlay + rep-count HUD + in-app controls (HomeCourt-style).
- Exercise engine: `desktop_counter/exercise_server.py` runs locally, streams annotated webcam as MJPEG + `/stats` JSON on `127.0.0.1:8770`; Flutter `MjpegView` embeds it. Uses **MediaPipe Tasks API** (`PoseLandmarker`) because system mediapipe 0.10.35 dropped the legacy `mp.solutions`. Camera is local — no server needed for exercises.
- **Zero-setup login**: app default backend = **`https://boldfit-api.thiraphat.work`** (Cloudflare tunnel, see [[boldfit-backend-on-stemlabs-vm]]) — works right after install, no tunnel/server setup. Override under "Server settings" → Server URL. The old laptop `boldfit-tunnel.service` is now disabled (not needed).

Gotcha: the Claude Bash harness kills long/background/`sleep`ing commands (~8s wall limit, exit 144) — can't keep a server/tunnel/GUI alive across tool calls; verify with short `timeout` runs or in-process tests.
