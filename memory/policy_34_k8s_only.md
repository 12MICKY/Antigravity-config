---
name: policy-34-k8s-only
description: ".34 runs workloads on K3s only — no raw `docker run` services; docker engine kept just for image build/push"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 01c34b6a-a684-4f46-89e7-52a5e7f123af
---

As of 2026-06-10 Thiraphat wants **all services on .34 to run in K3s, not raw docker containers**. All previous raw-docker workloads (boldfit-repo-notifier, boldfit-web, map-pins) were migrated to K3s Deployments in ns `apps`.

**Why:** single orchestrator, K3s already runs everything else (cloudflared, runners, monitoring); raw docker containers were invisible to the cluster.

**How to apply:** for a new service on .34 — build image, push to in-cluster registry `10.33.1.34:5000/<name>:latest`, write manifest in `~/k3s-manifests/apps/<name>.yaml` (Deployment + Service NodePort; PVC local-path if stateful; Secret via `--from-env-file` for env), `kubectl apply`. Expose publicly by pointing cloudflared ConfigMap at the NodePort (or reuse the old port number so the tunnel entry doesn't change). Docker engine on .34 stays only for `docker build`/`docker push`.

Related: [[infra_servers]] [[workflow_patterns]] [[boldfit_repo_notifier]] [[map-pins-app]]
