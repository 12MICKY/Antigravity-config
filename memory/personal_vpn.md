---
name: personal-vpn
description: "Thiraphat's PERSONAL WireGuard hub on own VPS — home<->Chula, separate from work"
metadata: 
  node_type: memory
  type: project
  originSessionId: edd2c70c-c44a-41c6-8988-e2692d2ba920
---

**Personal WireGuard VPN (set up 2026-06-02)** — Thiraphat's OWN, fully separate from the Stemlabs/work CRS VPN ([[vpn-crs-rbac]]), tailscale, and the workplace VPS. Hub-and-spoke on his own VPS.

- **Hub = own VPS `165.101.64.45`** (`thiraphatvps`, Ubuntu 24.04, root pw `sEk7c^VsC7`, 1vCPU/1GB). **Latency from CU laptop = ~4ms** (provider 165.101.64.x is local — same /24 as the WORK VPS .38 but THIS one .45 is Thiraphat's). WireGuard `wg0`: net **10.99.0.0/24**, VPS=10.99.0.1, **listen udp 51820**, ip_forward=1, FORWARD-accept via PostUp. Config `/etc/wireguard/wg0.conf`; all peer keypairs generated + stored in `/etc/wireguard/{vps,c34,home,laptop,phone}.{key,pub}`. **VPS pubkey `+bbh0wsho6S0DnATShV1eKY79CflRLS1mcGLmuaEJwM=`**. `wg-quick@wg0` enabled.
- **Peers / IP plan:** .34=10.99.0.2 · home pve=10.99.0.3 · laptop=10.99.0.10 · phone=10.99.0.11.
- **"Narrow Chula" design (per user):** at CU only the user's own server **`10.33.1.34`** is exposed — VPS routes ONLY `10.33.1.34/32` to the .34 peer, NOT the whole 10.33.1.0/24 Stemlabs infra. **Home = whole `10.10.10.0/24`** (home pve routes it). So the personal VPN touches only his own boxes.
- **.34 (Chula)**: `/etc/wireguard/wg0.conf`, Address 10.99.0.2/24, AllowedIPs `10.99.0.0/24,10.10.10.0/24`, keepalive 25 → tunnel UP (ping VPS 2.9ms). It only exposes itself (10.33.1.34 is its own eth0 IP, local-delivered).
- **laptop**: imported to NetworkManager as connection **`home`** (renamed from personal-vpn 2026-06-02; interface `personalvpn`; autoconnect=no, toggle like `stemlabs`); `nmcli con up/down home`. Verified laptop→10.33.1.34 = 3ms through it. Conf `~/Downloads/personal-vpn-laptop.conf`. ⚠️ while UP it routes 10.10.10.0/24 into the (until-configured) home tunnel → home unreachable until home pve peer is up; down it to fall back.
- **phone**: conf `~/Downloads/personal-vpn-phone.conf` + QR PNG `~/Downloads/personal-vpn-phone.png` (qrencode absent; used python `qrcode`).
- **home pve `10.10.10.10`** (hostname `homelab`, physical, root pw `thiraphatroot`) — DONE: wg0 Address 10.99.0.3/24, peer=VPS, AllowedIPs `10.99.0.0/24,10.33.1.34/32`, keepalive 25, ip_forward=1, `iptables -t nat -A POSTROUTING -s 10.99.0.0/24 -o vmbr0 -j MASQUERADE` (LAN bridge = vmbr0) so remote peers reach all 10.10.10.x. `wg-quick@wg0` enabled.
- **VERIFIED end-to-end 2026-06-02 (all single-digit ms):** laptop→home subnet (10.10.10.12/.3) ✓, laptop→.34 2.4ms, home↔.34 site link ~5ms, home→VPS 4.4ms. Replaces the old tailscale CU↔home Singapore-DERP path. (phone peer 10.99.0.11 keys ready, not yet connected.)
- **Management UI = wg-portal v2** (added 2026-06-02, Docker on VPS). Web at **http://10.99.0.1:8888 — VPN-only** (bound to the wg IP, not public; must connect VPN first). Login **`admin@thiraphat.work` / `WgPortal-Thira#2026`** (config `/opt/wg-portal/config/config.yaml`, data `/opt/wg-portal/data`, sqlite). Runs `--network host --cap-add NET_ADMIN`, `restart unless-stopped`; `import_existing: true` imported wg0 + all 4 peers. **wg-portal now MANAGES wg0** (netlink) → `wg-quick@wg0` was `systemctl disable`d (interface stays up; wg-portal recreates on boot). Manage peers/QR/status/toggle via the web page. Metrics :8787 blocked from public via iptables (NOT persisted across reboot — re-add or use iptables-persistent). Chose wg-portal over wg-easy because wg-easy can't do site-to-site subnet routing (would break whole-home 10.10.10.0/24 access).
- Reason for building this: tailscale was relaying CU↔home through Singapore DERP (~32ms, capped); own VPS hub in-country = ~4ms direct. See [[domain-separation]].

Related: [[domain-separation]] [[infra-servers]]
