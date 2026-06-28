---
name: network-engineer
description: Hardcore reference guidelines and blueprint topologies for Thiraphat's multi-site VPN, VLANs, Cloudflare tunnels, and Mikrotik routing.
---
# Hardcore Network Engineering & Topology Blueprint

This reference skill defines the actual routing, VPN topologies, and server mappings for Thiraphat's infrastructure.

---

## 1. Network Infrastructure & Server IP Map

| Node / Host | IP Address | Subnet / VLAN | Role | Notes |
|---|---|---|---|---|
| **prod-server** | `10.33.1.34` | VLAN 10 (Prod) | K3s CP / CF Tunnel Host | Registry :5000, map-pins :18091 |
| **dev-server** | `10.33.1.32` | VLAN 10 (Prod) | K3s Worker / Playgrounds | Untested builds, experiments |
| **pteachlab** | `10.33.1.33` | VLAN 10 (Prod) | Web/DB (pteachlab.com) | Next.js, PG, pw: `Yaimakmak1234` |
| **node5 (VM120)** | `10.33.1.27` | Chula LAN (vmbr0) | genius-lab-nextjs2 Host | PM2, PG, NO internet (captive portal) |
| **VM 102 (Lab)** | `10.33.1.24` | VLAN 10 (Prod) | Native Postgres (PG14) | PAM authentication (Linux users) |
| **PVE Cluster** | `10.33.1.44` | VLAN 10 (Prod) | 5-node Proxmox VE | Virtualization Control Plane |
| **CHR VM** | `10.33.1.45` | VLAN 10 (Prod) | Mikrotik CRS / Router VM | Core routing and gateway |
| **stemlabs-vps**| `165.101.64.38`| Public (SSH :2222) | BoldFit Backend Host | API+PG :8001, PAM, SSH tunnel |
| **personal-vps**| `165.101.64.45`| Public (wg hub) | WG Hub / UDP forwarder | Port :51822 |

---

## 2. Multi-Tiered VPN & Tunnel Architecture

### A. WireGuard Hub Topology
- **Hub VPS**: `165.101.64.45:51822` (UDP forwarder)
- **Tunnels**:
  - `wg0`: Connects public `stemlabs-vps` (VM 102) to the VPS.
  - `wg1`: Connects local Mikrotik CRS to the VPS.
- **Routing**: Tunnel packets are routed between Home LAN (`10.10.10.0/24`) and Chula LAN (`10.33.1.0/24` via `.34` gateway) with latency ~4ms.
- **Strict MTU**: WireGuard virtual interfaces MUST use `MTU 1340` to avoid WAN fragmentation.

### B. Cloudflare Tunnel (K3s HA)
- **Tunnel ID**: `51f79d1f-24e5-4e2a-a1e4-c56b21d96bd2`
- **Kubernetes Deployment**: Runs in namespace `apps` with **2 replicas** split across `.34` and `.32` (HA setup).
- **Configuration**: Managed via **ConfigMap `cloudflared-config`** and **Secret `cloudflared-credentials`** (manifest at `~/k3s-manifests/apps/cloudflared.yaml`).
- **Registration**: To add a new public service on `*.thiraphat.work`:
  1. Execute: `~/k3s-manifests/apps/cloudflared-add-service.sh <hostname>` (updates DNS + ConfigMap + restarts deployment).
  2. Create the Traefik `IngressRoute` pointing to the service.

### C. Fortinet DPI Plain SSH Bypass (Workplace Tunnel)
- **Problem**: Workplace network uses Fortinet which blocks all WireGuard/Tailscale VPN handshakes.
- **Solution**: Establish a plain SSH port-forwarding loop to the public VPS host:
  `ssh -N crs-tunnel`
  This routes traffic out of the restricted workplace through SSH port `22` (typically open) to access WinBox and PVE web panels.

### D. Moonraker Printer Tunnels (Snapmaker U1)
- **Hosts**: 2× Snapmaker U1 3D Printers.
- **Auth**: Authenticate via `X-Api-Key` headers.
- **trusted_clients**: Ensure `100.64.0.0/10` is added to `moonraker.conf` to prevent AppImage/Flatpak OrcaSlicer connection drops.
- **LXC 116 (node1)**: Runs `ct116` tunnel for `stemlabs2.work` Grafana monitoring route.
