---
name: proxmox-datacenter
description: Reference guidelines for PVE multi-node datacenter configuration, shared storage (Ceph/ZFS), cluster nodes, SDN, and High Availability (HA).
---
# Proxmox Datacenter Reference

Instructions for managing cluster-wide Proxmox datacenter configurations:
- **PVE Cluster**: 5-node cluster at `10.33.1.44` on subnet `10.33.1.0/24`.
- **Shared Storage**: Datastores map to `pbs-node3` and local pools. Maintain proper storage configuration in `/etc/pve/storage.cfg`.
- **High Availability (HA)**: Monitor cluster status using `pvecm status`. Ensure HA groups and fencing policies are defined correctly to prevent split-brain scenarios.
- **SDN**: Manage virtual bridges (e.g. `vmbr0` Chula LAN gateway) and software-defined network zones cleanly.
