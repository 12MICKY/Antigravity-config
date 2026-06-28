---
name: proxmox-manager
description: Reference for managing Proxmox VMs, LXC containers, resource allocation, template creation, PVE API tokens, and user permissions.
---
# Proxmox VM & Container Manager Reference

Instructions for managing individual virtualization nodes, resource provisioning, and permissions:
- **API Token Access**: Connect automation tools using PVE API tokens (e.g. `PVEAPIToken=user@pve!tokenid=uuid`).
- **Resource Allocation**: Provision CPU sockets/cores, memory limits, and disk sizes. Avoid over-provisioning production cores.
- **Templates**: Manage base templates (`9000` to `9002` cloud-init) for cloning. Ensure templates are marked read-only.
- **LXC Configuration**: Configure unprivileged containers for security. Setup correct user/group mapping if mounting host paths.
