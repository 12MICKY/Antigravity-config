---
name: proxmox-datacenter
description: Reference guidelines for PVE multi-node datacenter configuration, shared storage (Ceph/ZFS), cluster nodes, SDN, and High Availability (HA).
---
# Hardcore Proxmox Datacenter Reference

Reference manual for 5-node cluster networking, High Availability, and Ceph configuration.

---

## 1. Multi-Node Cluster Configuration
- **Hypervisor Core**: 5-node Proxmox VE cluster (`10.33.1.44`).
- **Cluster Status**: Check node connectivity and vote distribution:
  ```bash
  pvecm status
  pvecm nodes
  ```
- **Password Policies**: Root passwords vary across cluster nodes. Keep distinct keys in secure keyrings.

---

## 2. High Availability (HA) & Fencing
- **Config Path**: `/etc/pve/ha/resources.cfg` and `/etc/pve/ha/groups.cfg`.
- **Fencing (Watchdog)**: Ensure hardware watchdog (ipmi/fencing cards) is configured to automatically fence split-brain nodes.
- **CLI Commands**:
  ```bash
  # Check active HA status
  ha-manager status
  
  # Add a VM to the HA management pool
  ha-manager add vm:<vmid> --group=failover-nodes --state=started
  ```

---

## 3. Ceph & Shared Storage Policies
- **Ceph Health**: Check Ceph health status on PVE hosts:
  ```bash
  pveceph status
  ceph -s
  ```
- **Pool Mapping**: Shared pools configured as RBD storage (`/etc/pve/storage.cfg`).
- **Disk Replacement**: When rebuilding disks (e.g. OSD replacement), always verify OSD maps:
  ```bash
  ceph osd tree
  ceph osd out <osd_id>
  ```
