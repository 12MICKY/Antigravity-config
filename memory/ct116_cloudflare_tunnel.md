---
name: ct116-cloudflare-tunnel
description: Cloudflare tunnel ct116 in LXC 116 (node1) for stemlabs2.work domain
metadata: 
  node_type: memory
  type: infra
  originSessionId: 9998930d-f082-42cd-92a4-1a71318cb90b
---

**CT 116 `cloudflared-tunnel`** — LXC on **node1 (10.33.1.20)**, Debian 12, IP **10.33.1.31**, root pw `Yaimakmak888`. Dedicated Cloudflare tunnel host for the **stemlabs2.work** domain (separate from the personal `*.thiraphat.work` K3s tunnel — see [[domain-separation]]).

- **Tunnel:** name `ct116`, ID `d91a47df-bad9-4663-a3b0-cf307972459c`. Zone `stemlabs2.work` (zoneID `9f62652732f7d1457f252bbc8f2d6955`, accountID `09df96c85339b919f5d4ce98a47b3568`). Created 2026-05-31. cloudflared 2026.5.2 (installed via .deb).
- **Auth:** origin cert `/root/.cloudflared/cert.pem` (already present), creds JSON `/root/.cloudflared/d91a47df-...json`.
- **Config:** `/etc/cloudflared/config.yml` (ingress list). Runs as **systemd `cloudflared.service`** (enabled, `--config /etc/cloudflared/config.yml tunnel run`), NOT docker.
- **Routes:** `grafana.stemlabs2.work` → `http://10.33.1.46:3000` (Grafana, see [[proxmox-cluster]]). Verified HTTP 200.
- **Add a service:** edit `/etc/cloudflared/config.yml` (add hostname/service before the `http_status:404` catch-all) + `cloudflared tunnel route dns ct116 <sub>.stemlabs2.work` + `systemctl restart cloudflared`. Enter CT: `sshpass -p 'Yaimakmak888' ssh -t -o PreferredAuthentications=password -o PubkeyAuthentication=no root@10.33.1.20 'pct enter 116'`.

Related: [[snapmaker-u1-printers]] (also on stemlabs2.work), [[infra-servers]]
