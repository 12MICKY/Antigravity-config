---
name: proxmox-cli
description: Reference for direct shell administration of Proxmox hosts using CLI commands (qm, pct, pvesh, pvesr, pveversion).
---
# Proxmox Host CLI Reference

Instructions for managing Proxmox VE from the shell:
- **VM Commands (`qm`)**:
  - Start VM: `qm start <vmid>`
  - Stop VM: `qm stop <vmid>`
  - Clone template: `qm clone <template_id> <new_id> --name <name>`
- **LXC Commands (`pct`)**:
  - Start Container: `pct start <vmid>`
  - Enter console: `pct enter <vmid>`
  - Set resource limits: `pct set <vmid> -memory 1024 -cores 2`
- **Replication & Versioning**:
  - Check version: `pveversion -v`
  - Manage replication jobs: `pvesr status`
- **Configuration Path**: PVE cluster config filesystem is located at `/etc/pve/` (which mounts automatically as pmxcfs).
