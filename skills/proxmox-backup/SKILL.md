---
name: proxmox-backup
description: Reference guidelines for PBS (Proxmox Backup Server), target configurations, backup jobs, schedule logs, garbage collection, and recovery/restore workflows.
---
# Hardcore Proxmox Backup Server (PBS) Operations

Reference manual for PBS CT 104 running on node 3 and datastore configurations.

---

## 1. Storage & Datastore Mapping
- **LXC Container**: **CT 104** (runs PBS daemon).
- **Physical Datastore**: `/dev/sdb` (previously `ex-osd.0`, formatted to ext4/xfs), size 1TB.
- **PVE Storage Config (`/etc/pve/storage.cfg`)**:
  ```ini
  pbs: pbs-node3
          server 10.33.1.104
          datastore pbs-node3
          username backup-user@pbs
          password BACKUP_USER_PASSWORD
          fingerprint FINGERPRINT_HEX
          prune-backups keep-daily=7,keep-weekly=4,keep-monthly=12
  ```

---

## 2. Backup & Restore Operations (CLI)
Run backups manually or verify status via PVE host terminal:

```bash
# Trigger manual snapshot backup for a VM/LXC to PBS
vzdump <vmid> --storage pbs-node3 --mode snapshot --remove 0

# Restore a container from PBS snapshot
pct restore <new_vmid> pbs-node3:backup/ct/<source_vmid>/<backup_date_time>

# Restore a virtual machine from PBS snapshot
qmrestore pbs-node3:backup/qemu/<source_vmid>/<backup_date_time> <new_vmid>
```

---

## 3. Maintenance & Garbage Collection (CLI)
Execute maintenance tasks on the PBS container (CT 104):

```bash
# Run garbage collection on PBS to reclaim pruned blocks
proxmox-backup-manager garbage-collection start pbs-node3

# Start datastore verification task
proxmox-backup-manager verify pbs-node3

# Check backup task progress and active log streams
proxmox-backup-manager task list
```
