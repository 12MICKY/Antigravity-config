---
name: vpn-crs-rbac
description: "VPN v2 — WireGuard server moved onto CRS (MikroTik), admin/user RBAC managed in WinBox, VPS is just UDP forwarder"
metadata: 
  node_type: memory
  type: project
  originSessionId: 038e4eb6-fca6-4a18-80c3-b4f7233d1d59
---

**VPN v2 (set up 2026-05-31)** — WireGuard server ย้ายจาก wg-easy (VPS) มาอยู่บน **CRS (MikroTik 10.33.1.45)** เอง; จัดการ peers + RBAC ผ่าน **WinBox**. **wg-easy ถอดทิ้งหมดแล้ว** (container/image/files/helper + masq 172.16/12→wg0 บน VPS ลบ 2026-05-31). laptop `stemlabs` (NM + netdev) ชี้ CRS endpoint :51822 แล้ว. Full details/WinBox how-to ใน `~/Projects/chr-proxmox/NOTE.md` ("VPN v2"). See [[proxmox-cluster]].

- **ทำไม VPS ยังต้องมี:** CRS อยู่หลัง CU double-NAT ไม่มี public IP. VPS = UDP forwarder: `DNAT eth0:51822 → 10.200.0.2:51822` + `SNAT -o wg0 --to 10.200.0.1` (persist netfilter-persistent).
- **CRS:** interface `wg-clients` listen 51822, IP **10.9.0.1/24**, **mtu 1340** (สำคัญ — double-tunnel client→VPS→wg0→CRS; ถ้า 1420 เว็บใหญ่ค้างแม้ ping ได้). server pubkey `oZp+X/wInIJ2pr+GtRQWZSZ043NMiilgJcKwenJpmVw=`. client endpoint = `165.101.64.38:51822`, DNS 10.33.1.47.
- **RBAC by IP range** (CRS firewall, in-interface=wg-clients): admin=`10.9.0.0/25` (full + CRS WinBox/SSH), user=`10.9.0.128/25` (เฉพาะ 10.33.1.0/24 + 10.33.99.0/25; ซ่อน Proxmox/CRS via address-list `vpn-hidden`, no client-to-client, ping CRS ไม่ได้). **เลือกช่วง IP ตอน add peer = ได้ role อัตโนมัติ ไม่ต้องแตะ firewall.**
- **address-list `vpn-hidden`** = proxmox 10.33.1.20-23 + .44, CRS 10.33.1.45 + 10.33.99.1, 10.9.0.0/24.
- **เพิ่มคนใน WinBox:** WireGuard→Peers→+ → interface=wg-clients, วาง client PublicKey+PresharedKey, Allowed Address=`10.9.0.X/32` (2–127=admin / 128–254=user), comment role. Client .conf ประกอบเอง (WinBox ไม่ gen). ลบ=ลบ peer.
- **Peers ปัจจุบัน:** admin = thiraphat=10.9.0.2, saral=10.9.0.4 (10.9.0.3 ว่าง — thiraphatconnex ถูกลบ 2026-06-02) · printer-only = StemlabPrintfarm=10.9.0.5 · user = Bhira=10.9.0.128, Phurit=10.9.0.129, Theer=10.9.0.130. Configs+QR: `~/Projects/chr-proxmox/wg-clients-configs/` (+ deliverables `~/Downloads/vpn-configs/`). backup CRS: `backups/{pre,post}-wgclients-*.rsc`.
- **Add peer via SSH (no WinBox):** generate locally `priv=$(wg genkey); pub=$(echo $priv|wg pubkey); psk=$(wg genpsk)` → CRS `/interface/wireguard/peers/add interface=wg-clients name=<n> public-key="$pub" preshared-key="$psk" allowed-address=10.9.0.X/32 persistent-keepalive=25s comment="role:admin|user"` → build .conf (server pubkey `oZp+X/wInIJ2pr+GtRQWZSZ043NMiilgJcKwenJpmVw=`, Endpoint `165.101.64.38:51822`, DNS 10.33.1.47, MTU 1340, PersistentKeepalive 25). Keepalive 25 also makes them show online in the realtime rx-based VPN panel.
- **role ย่อ:** admin (10.9.0.0/25) = เข้าได้ทุกอย่าง + CRS WinBox/SSH. user (10.9.0.128/25) = เข้าแค่ service ในวง 10.33.1.0/24 + lab 10.33.99.0/25; **ทำไม่ได้:** Proxmox, CRS/WinBox, **Grafana .46 + AdGuard .47 dashboard** (2026-05-31), เห็น peer คนอื่น, วง mgmt+printers, เน็ตผ่าน VPN.
- **ข้อยกเว้น DNS:** user ยังเข้า AdGuard `10.33.1.47:53` (udp+tcp) ได้เพราะเป็น DNS ของเขา (rule allow วางก่อน hidden-drop ใน forward chain) — บล็อกแค่เว็บ/ping ของ .47 ส่วน .46 บล็อกหมด.
- tested end-to-end จาก laptop ผ่านเน็ตจริง: user→grafana/adguard OK, proxmox/CRS BLOCKED; admin→ทุกอย่าง OK.

### Updates 2026-06-10
- **Client configs now live in GitHub repo `12MICKY/vpn-configs`** (per-person `<name>.conf` + `<name>-qr.png`): thiraphat, saral, StemlabPrintfarm, Bhira, Phurit, Theer. The old `~/Projects/chr-proxmox/...` paths are GONE — edit configs in the repo, regen QR (`segno`, no qrencode), commit+push.
- **Laptop wg connections are netplan-managed** (NOT plain NM keyfiles — `/etc/NetworkManager/system-connections/` is empty; generated files in `/run/...`). Source = **`/etc/netplan/90-NM-<uuid>.yaml`** (sudo pw `200152`): `1d1269f4-...`=tunnel **thiraphat** (NM name `stemlabs`), `d111bf95-...`=**printfarm** (StemlabPrintfarm), `netplan-personalvpn`=home. To change AllowedIPs: edit the YAML `peers: allowed-ips:` list → `sudo netplan apply` (regenerates the NM conn). `nmcli import` fails non-interactively (polkit). NB laptop's live thiraphat allowed-ips had drifted from repo (has 10.15.5.157 + 10.100.0.0/24).
- **To grant a VPN peer access to a workplace host (e.g. did `10.15.5.152` on 2026-06-10, like printers 10.15.5.66/160):** (1) add `<ip>/32` to AllowedIPs in the repo config + the device's config (laptop=netplan). (2) **admin peers (10.9.0.0/25) need NO CRS change** (rule 11 full access; CRS reaches 10.15.5.x via its Chula default gw + masquerade out ether1, no per-IP route). (3) **user peers (10.9.0.128/25) ALSO need a CRS forward rule** `accept src=10.9.0.128/25 dst=<ip> in-interface=wg-clients` placed **before** the `vpn-user: deny rest` rule (`place-before=[find comment="vpn-user: deny rest"]`).
