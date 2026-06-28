---
name: proxmoxauto-vm-bot
description: "Discord bot (/promox) that creates Proxmox VMs — Go, runs in LXC 200, cloud-init templates, free-IP scan"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7b2e119c-62f2-485c-9cf1-3ea56030eaa4
---

**Proxmoxauto bot** — Discord `/promox` slash command creates a Proxmox VM: pick **Node** (any of node1–5) / **OS** / **free IP** (10.33.1.x), then a modal for **hostname / username / password / RAM(MB) / Disk(GB)**. English UI. Built 2026-06 on the Satit-M cluster (see [[proxmox-cluster]]).

- **Language: Go** (rewritten from Python — user wanted the fastest language). `discordgo` + Proxmox REST API directly. Source: `~/Projects/proxmoxauto-bot/main.go` (single static binary `proxmoxauto-bot`, `CGO_ENABLED=0 go build`). Old Python version at `~/Projects/satitm-bot/bot.py` (deprecated).
- **Runs as LXC 200 `Promoxauto-bot`** @ `10.33.1.48` on node5 (Debian 12, local-lvm 8G). systemd **`proxmoxauto-bot.service`**, `EnvironmentFile=/opt/satitm-bot/.env`, binary at `/opt/satitm-bot/proxmoxauto-bot`. The CT has internet on vmbr0 (captive portal does NOT block it) and can ping/ARP-scan the LAN.
- **Cloud-init templates** (ceph-rbd, on node5, serial console required): **9000 Ubuntu 24.04**, **9001 Debian 13**, **9002 Alpine (low-RAM, 0.2G disk)**. Made via `qm create … --serial0 socket --vga serial0` → import cloud image → `--ide2 ceph-rbd:cloudinit` → `qm template`. Clone flow (what the bot does): `qm clone <tmpl> <newid> --full --target <node> --storage ceph-rbd` → config memory/ciuser/cipassword/ipconfig0(gw 10.33.1.1)/nameserver(10.33.1.47) → `qm disk resize scsi0 <G>` → start. **Verified: clone→boot→IP in ~10s.**
- **Free-IP logic** = same as `/usr/local/bin/netsatitm` on .34: scan **10.33.1.20-35 + .41-49 (excl .42)**, IN-USE if ping replies OR a valid ARP entry, else FREE. The Go bot replicates this (concurrent ping + `ip neigh`).
- **Proxmox API token: `root@pam!satitm-bot`** (privsep=0 = full perms), secret in the CT's `.env`. Discord bot = **"Steamlab Assistant"** app id `1456664823373889536`, in guilds DEV LAB / Stemlab printfarm 2 Admin / CUD Student Print Lab. Commands registered **per-guild** (instant); global commands cleared to avoid dupes.
- Node5 SSH: `SSHPASS='Yaimakmak888' sshpass -e ssh root@10.33.1.44`; manage CT via `pct exec 200 -- …`. Reach the cluster from the laptop via the `home` wg VPN (`nmcli con up home`).
