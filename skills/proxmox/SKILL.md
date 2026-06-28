---
name: proxmox
description: Hardcore reference blueprints for Thiraphat's 5-node Proxmox cluster, PBS CT 104 backup policy, and VM/LXC automation templates.
---
# Hardcore Proxmox Cluster & Virtualization Guide

This reference skill defines the actual configurations, backup targets, and automation details for the PVE cluster (`10.33.1.44`).

---

## 1. PVE Cluster & Storage Architecture
- **Cluster Control**: 5-node PVE cluster hosted on subnet `10.33.1.0/24`. Note that root passwords differ between some nodes.
- **Backup Host (PBS)**: Proxmox Backup Server runs inside Container **CT 104** on node 3.
  - **Datastore**: 1TB mounted disk `sdb` (previously `ex-osd.0`).
  - **Storage ID in PVE**: `pbs-node3`.
  - **Backup Schedule**: Automated daily backups for all active VMs/LXCs trigger at **19:00**.
  - **Maintenance**: GC (Garbage Collection), Verify, and Prune policies are configured natively in PBS CT 104.

---

## 2. VM/LXC Provisioning Automation
- **Go Automation Bot**: Discord bot listening for `/proxmox` commands to trigger Go script provisioning.
- **Free-IP Scan**: The provisioning script runs `netsatitm` (scanning local subnets) to find free IPs before configuring the container interface.
- **Templates**:
  - `9000`: Ubuntu 22.04 LTS cloud-init template.
  - `9001`: Ubuntu 24.04 LTS cloud-init template.
  - `9002`: Alpine/Debian lightweight template.
- **Node5 VM 120 (pteachlab)**:
  - Static IP: `10.33.1.27` bound to virtual bridge `vmbr0` (Chula LAN gateway).
  - Network Restriction: Capture portal blocks WAN access. Node 120 has **NO internet** access.

---

## 3. LXC Network and Storage Mounts

### Mount Point Patterns:
Always mount persistent directories from ZFS/Ceph pools or local datastores for data retention:
```bash
# Add mount points to LXC config (on PVE node terminal)
pct set 102 -mp0 /mnt/pve/storage-pool/data,mp=/opt/data
```

### Virtual Machine Cloud-Init Setup:
For manual VM templates, always verify the serial console is enabled and cloud-init drive is generated:
```bash
qm set <vmid> --serial0 socket --vga serial0
qm set <vmid> --ide2 local-lvm:cloudinit
```
