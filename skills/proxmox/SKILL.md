---
name: proxmox
description: Guidelines for managing Proxmox VE (PVE) virtual environments, VM automation, LXC configurations, and backups.
---
# Proxmox VE Skill

Instructions for managing Proxmox hypervisors:
- **Cluster**: 5-node cluster is hosted at 10.33.1.44. Router VM is at 10.33.1.45.
- **VM/LXC Automation**: Use standard templates (9000-9002) for cloning new instances. Run free-IP scans before deploying LXC.
- **Backups**: Integrate backups with PBS CT104 (Proxmox Backup Server) on node3. Verify backup logs and prune policies.
- **Security**: Manage authentication carefully, isolate container network interfaces, and configure Netwatch for vital router/PVE nodes.
