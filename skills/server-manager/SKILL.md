---
name: server-manager
description: Reference guidelines for remote SSH server management, private docker registries, docker swarm/k3s deployment configs, and port checking.
---
# Hardcore Server Manager Reference

Reference manual for production host management, private registries, and Docker Swarm deployments.

---

## 1. Remote SSH Execution Pattern
Use password authentication securely with `sshpass` (password `200152`). Escalation inside commands requires passing the password to `sudo -S`:

```bash
# Secure remote SSH execution pattern
SSHPASS='200152' sshpass -e ssh -o StrictHostKeyChecking=no thiraphat@10.33.1.34 "echo '200152' | sudo -S docker ps"

# Secure remote SCP execution pattern
SSHPASS='200152' sshpass -e scp -o StrictHostKeyChecking=no /path/to/local/file thiraphat@10.33.1.34:/path/to/remote/
```

---

## 2. Cluster Deployment & Registries

### A. Production Host (.34) vs Dev Host (.32)
- **Production Host (.34)**: Serves K3s control-plane, Cloudflare tunnel, and user-facing services. Do NOT run experimental or untested code here.
- **Dev Host (.32)**: Staging worker node. Use for playgrounds and throwaway testing.
- **K3s Manifests**: Deploy via Traefik IngressRoute. Manifest files are kept at `~/k3s-manifests/apps/`.

### B. Private Docker Registry
- **Endpoint**: `10.33.1.34:5000` (registered in `registries.yaml` for insecure pull).
- **Physical Storage Path**: `/var/lib/rancher/k3s/storage/registry-data`.

### C. Docker Swarm Stack Deployment
- **Command**:
  ```bash
  docker stack deploy -c <file>.yml <stack_name> --with-registry-auth
  ```
- **Config Management**: Use SHA-versioned configuration hashes to force updates on immutable Swarm service definitions.

---

## 3. Port Auditing & Diagnostics
```bash
# Inspect all listening TCP ports on the server
lsof -nP -iTCP -sTCP:LISTEN

# Check if a specific service port is bound
ss -tlnp | grep 8080
```
