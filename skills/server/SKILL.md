---
name: server
description: Reference for server administration, ports checking, Docker Swarm deployments, private registries, and K3s clusters.
---
# Server Skill

Instructions for managing server infrastructure:
- **Production Server (.34)**: Serves K3s control-plane, Cloudflare tunnel host, and user-facing services. Do NOT run experimental builds on .34.
- **Development Server (.32)**: Dev playground for experiments and untested code.
- **Docker Swarm**: Deploy stacks using `docker stack deploy -c <file>.yml <stack> --with-registry-auth`. Check listening ports using `lsof -nP -iTCP -sTCP:LISTEN`.
- **Private Registry**: Access the local registry at `10.33.1.34:5000` with data stored at `/var/lib/rancher/k3s/storage/registry-data`.
