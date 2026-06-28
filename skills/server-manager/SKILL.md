---
name: server-manager
description: Reference guidelines for remote SSH server management, private docker registries, docker swarm/k3s deployment configs, and port checking.
---
# Server Manager Reference

Instructions for administrating production and staging host servers:
- **SSH Protocol**: Use password authentication with `sshpass` for remote commands:
  `SSHPASS='200152' sshpass -e ssh -o StrictHostKeyChecking=no thiraphat@<IP> "<cmd>"`
- **Production Server (.34)**: Runs K3s control-plane. Apply strict K8s manifests in `~/k3s-manifests/apps/` instead of raw Docker.
- **Development Server (.32)**: K3s worker / playground for throwaway deployments.
- **Docker Registry**: Private local registry hosted at `10.33.1.34:5000`. Storage path: `/var/lib/rancher/k3s/storage/registry-data`.
- **Port Auditing**: Audit listening sockets on the host using `lsof -nP -iTCP -sTCP:LISTEN` or `netstat -tuln`.
