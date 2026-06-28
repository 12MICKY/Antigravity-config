---
name: data-center-engineer
description: Reference guidelines for managing Proxmox cluster (10.33.1.44), PBS CT104, virtualization bots (Go/LXC), and Swarm stack deployments.
---
# Data Center Engineer Skill

Instructions for managing virtualization and host servers:
- **Proxmox Cluster**: 5-node cluster at 10.33.1.44. Datastores and backups configured daily at 19:00 via PBS CT104.
- **Proxmox VM Bot**: Go bot creating Proxmox LXC/VM containers using cloud-init templates (9000-9002).
- **Swarm Stack Deployment**: Deploy using `docker stack deploy -c <file>.yml <stack> --with-registry-auth`. Raw Docker services not allowed on .34 (k8s-only policy).
- **Virtual Machine Templates**: Cloud-init VM templates are named/indexed from 9000 to 9002 on Proxmox. Ensure free-IP scan is run prior to launching new LXC.
