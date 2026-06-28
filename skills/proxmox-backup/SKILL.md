---
name: proxmox-backup
description: Reference guidelines for PBS (Proxmox Backup Server), target configurations, backup jobs, schedule logs, garbage collection, and recovery/restore workflows.
---
# Proxmox Backup (PBS) Reference

Instructions for managing Proxmox Backup Server (PBS) configurations and operations:
- **Backup Host**: Proxmox Backup Server hosted inside Container **CT 104** on node 3.
- **Datastore ID**: `pbs-node3` maps to physical storage `/dev/sdb` (ex-osd.0).
- **Schedules**: Automated daily VM/LXC backups trigger at **19:00**.
- **Maintenance**:
  - **Prune Policy**: Keep last 7 daily, 4 weekly, and 12 monthly backups.
  - **GC (Garbage Collection)**: Verify and GC tasks run automatically to reclaim storage space.
- **Recovery**: Restore VM configurations or individual files directly from the PBS GUI or using client tools.
