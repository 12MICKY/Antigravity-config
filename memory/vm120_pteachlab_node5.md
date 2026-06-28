---
name: vm120-pteachlab-node5
description: "Proxmox VM 120 pteachlab on node5 — Ubuntu 24.04, static 10.33.1.27 on Chula LAN (vmbr0)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7afa5257-c5d0-4c5c-ac60-669a2c9c19a5
---

**Proxmox VM 120 `pteachlab`** created 2026-06-03 on node5 (10.33.1.44). Ubuntu 24.04 cloud image, 2 vCPU / 2GB / 32GB on local-lvm, onboot=1.

- **Login:** user `pteachlab` / pw `pteachlab` (SSH password auth enabled). NOT the same box as [[pteachlab-server]] (that = 10.33.1.33 pteachlab.com Next.js).
- **Network = vmbr0 (Chula/Satit-M LAN), STATIC `10.33.1.27/24` gw 10.33.1.1** (moved here 2026-06-03, user wanted Chula LAN). MAC BC:24:11:A6:A2:70. DNS 10.33.1.47 (AdGuard) + 1.1.1.1. Picked .27 because arping-confirmed free in .20–.35 (.20-.24/.26/.29/.31/.34 used; .25/.32/.33 assigned-but-off so avoided).
- **Reach it:** directly on Chula LAN (node5/laptop-on-LAN) AND via VPN (wg site-link routes 10.33.1.0/24). No VPN needed when on Chula LAN.
- **⚠️ NO internet (captive portal):** vmbr0 = Satit-M net behind captive portal — unregistered MAC gets port-443 redirected to `*.satitm.chula.ac.th`, so apt/npm/internet FAIL. App still runs (already built, local Postgres). To get internet back for updates: register MAC with Satit-M admin, or move NIC back to `crslan` (CRS NAT) temporarily. **History:** was on crslan 10.33.99.91 (internet via CRS) before this move.
- qemu-guest-agent installed → Proxmox reads IP/status over virtio-serial.
- **Cloud-init gotcha:** Proxmox's generated user-data does NOT set `ssh_pwauth` → SSH password login is OFF by default (works on console only). Fixed via custom snippet `local:snippets/pteachlab-user.yaml` (`--cicustom user=...`) that sets `ssh_pwauth: true` + writes `/etc/ssh/sshd_config.d/99-pteachlab.conf`. Snippet also pins apt to https + installs qemu-guest-agent. Re-run cloud-init: edit snippet (changes instance-id hash) → `qm cloudinit update 120` → `qm reset 120`.

Related: [[proxmox-cluster]], [[satit-m-fortinet-crs-access]]
