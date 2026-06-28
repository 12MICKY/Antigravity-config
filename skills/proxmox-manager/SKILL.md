---
name: proxmox-manager
description: Reference for managing Proxmox VMs, LXC containers, resource allocation, template creation, PVE API tokens, and user permissions.
---
# Hardcore Proxmox VM & Container Manager Reference

Reference manual for VM/LXC resource planning, templates, and PVE API permissions.

---

## 1. PVE API Token Configuration
Configure tokens to enable programmatic automation (e.g. for Go bot or IaC):

```bash
# 1. Create automation user
pveum user add automation-bot@pve --comment "Go Bot Executor"

# 2. Assign role permissions
pveum acl modify / --user automation-bot@pve --roles VM.Audit,VM.Console,VM.Config

# 3. Generate API Token
pveum user token add automation-bot@pve discord-bot --privsep 0
# Copy the returned Token ID and Secret Key!
```

---

## 2. VM/LXC Provisioning & Templates
- **Go Automation Flow**: Discord bot triggers `netsatitm` (IP ping scan) to determine a free IP before cloning.
- **Templates**:
  - `9000`: Ubuntu 22.04 LTS cloud-init template.
  - `9001`: Ubuntu 24.04 LTS cloud-init template.
  - `9002`: Debian/Alpine lightweight template.
- **Cloud-Init Configuration (CLI)**:
  ```bash
  # Assign cloud-init parameters to cloned VM
  qm set <vmid> --ipconfig0 ip=10.33.1.20/24,gw=10.33.1.1
  qm set <vmid> --nameserver 10.33.1.45 --searchdomain thiraphat.work
  qm set <vmid> --sshkey ~/.ssh/id_rsa.pub
  ```

---

## 3. Node5 VM 120 (pteachlab) Routing Restriction
- **Static IP**: `10.33.1.27` on virtual bridge `vmbr0` (Chula LAN).
- **Behavioral Rule**: VM 120 is strictly behind a captive portal. It has **NO internet** access. When deploying Next.js + Postgres PM2 stack here, ensure all dependencies are resolved offline or locally mirrored.
