---
name: proxmox-cli
description: Reference for direct shell administration of Proxmox hosts using CLI commands (qm, pct, pvesh, pvesr, pveversion).
---
# Hardcore Proxmox Host CLI Commands

Reference manual for direct shell administration of VM/LXC nodes on PVE hosts.

---

## 1. Virtual Machine Management (`qm`)
```bash
# Check running status of all VMs/LXCs
qm list

# Start, stop, and suspend VMs
qm start <vmid>
qm stop <vmid> --timeout 30
qm shutdown <vmid>
qm suspend <vmid>

# Setup serial redirection (vital for cloud-init console connection)
qm set <vmid> --serial0 socket --vga serial0

# Set hardware allocations dynamically
qm set <vmid> --cores 4 --sockets 1 --memory 4096 --balloon 1024
```

---

## 2. Container Management (`pct`)
```bash
# List containers and statuses
pct list

# Provision a new container from templates
pct create <vmid> local:vztmpl/ubuntu-24.04-default_amd64.tar.zst \
  -cores 2 -memory 1024 -net0 name=eth0,bridge=vmbr0,ip=10.33.1.20/24,gw=10.33.1.1

# Mount a host folder to a container (e.g. sharing volume)
pct set <vmid> -mp0 /mnt/pve/storage-pool/data,mp=/opt/data

# Enter the root shell of a running container directly
pct enter <vmid>
```

---

## 3. Advanced Cluster & Sync Utilities (`pvesh`/`pvesr`)
```bash
# Monitor the cluster synchronization status
pvesr status

# View status of active hypervisor nodes via API shell
pvesh get /nodes

# Check exact Proxmox kernel and package versions
pveversion -v
```
