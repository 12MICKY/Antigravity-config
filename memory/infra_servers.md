---
name: infra-servers
description: "Server IPs, SSH access, K3s cluster, Cloudflare tunnel details"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 4fb4bfef-9e28-4b26-8554-dc3ea4aecc5b
---

## Servers
| Name | IP | Role | Policy |
|---|---|---|---|
| thiraphat (.34) | 10.33.1.34 | K3s control-plane, Cloudflare tunnel host | **PROD** — user-facing services only · **personal server ของ Thiraphat** |
| thiraphat2 (.32) | 10.33.1.32 | K3s worker node (same cluster) | **DEV** — experiments, throwaway work |

> `.34 = personal server ของ Thiraphat` — ใช้เป็น home base สำหรับไฟล์ส่วนตัว, backup, config ต่างๆ ที่ไม่ใช่ Proxmox infrastructure

**Policy split rule:** Cluster still shared, but workloads now classified. Services that serve users (Nextcloud, Grafana, Immich, Authentik, telegram-bot, runners, tunnel) belong on `.34`. Throwaway experiments / unfinished builds / things-Thiraphat-is-trying belong on `.32`. Pin via existing `role=main`/`role=dev` node labels.

## SSH Access
```bash
SSHPASS='200152' sshpass -e ssh -o StrictHostKeyChecking=no thiraphat@<IP>
SSHPASS='200152' sshpass -e scp -o StrictHostKeyChecking=no <src> thiraphat@<IP>:<dst>
echo '200152' | sudo -S <cmd>   # sudo on remote
```

## CRS (MikroTik CHR 10.33.1.45)
- SSH: `SSHPASS='Yaimakmak888' sshpass -e ssh -o StrictHostKeyChecking=no admin@10.33.1.45`
- WinBox/SSH user: `admin`, password: `Yaimakmak888`

## Printer Network Routing (added 2026-06-21)
- 10.15.5.0/24 (workplace printers) routable from Chula cluster via:
  - CRS route: `10.15.5.0/24 → 10.200.0.1` (VPS wg-vps)
  - VPS wg0: hypervisor peer AllowedIPs includes `10.15.5.0/24`
  - Hypervisor (10.100.0.50): MASQUERADE iptables + wg0.conf PostUp/PostDown persist
- Verified: `.34 → 10.15.5.66` ping 2-9ms ✅

## K3s Cluster
- Control-plane: 10.33.1.34 (kubeconfig at ~/.kube/config locally and on .34)
- Worker: 10.33.1.32
- kubectl installed locally + on .34
- k9s installed on .34
- Manifests: ~/k3s-manifests/
- Node labels: `role=main` (.34), `role=dev` (.32)
- All stateful pods pinned to `role=main` (.34)

## Cloudflare Tunnel (running as K3s pod in apps namespace)
- **Tunnel ID:** `51f79d1f-24e5-4e2a-a1e4-c56b21d96bd2`
- **Config:** `/etc/cloudflared/config.yml` (root-owned on .34 host)
- **Write config:** `echo '200152' | sudo -S python3 -c "...open/read/write..."`
- **Apply changes:** `kubectl rollout restart deployment/cloudflared -n apps`
- **All service URLs in config use 10.33.1.34 (NOT 127.0.0.1)**
- **Add DNS record:**
  ```bash
  docker run --rm -v /home/thiraphat/.cloudflared:/home/nonroot/.cloudflared:ro \
    cloudflare/cloudflared tunnel route dns 51f79d1f-24e5-4e2a-a1e4-c56b21d96bd2 <sub>.thiraphat.work
  ```

## GitHub Actions Runners (K3s pods in apps namespace)
- node-34-custom, node-34-pinggps, node-34-grafana, node-34-telegram
- All mount Docker socket + repo directories
- ACCESS_TOKEN: <github_pat_masked>

## Private Registry
- 10.33.1.34:5000 (K3s pod, data at /var/lib/rancher/k3s/storage/registry-data)
- registries.yaml configured on both nodes for insecure pull

## Docker
- Docker daemon installed on .34 and .32 but NO containers running
- Docker Swarm: removed 2026-05-27
