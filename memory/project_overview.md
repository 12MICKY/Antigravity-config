---
name: project-overview
description: "Active projects, GitHub repos, and all services — fully migrated to K3s on .34/.32 (no Docker Swarm, no standalone Docker containers)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4fb4bfef-9e28-4b26-8554-dc3ea4aecc5b
---

## Infrastructure (as of 2026-05-27)
- .34 (thiraphat) = K3s control-plane
- .32 (thiraphat2) = K3s worker
- Docker Swarm: **removed** — migrated to K3s
- Docker daemon installed but zero containers running on it

## K3s Namespaces & Services

### namespace: apps
excalidraw:3003, promptpay-qr-app:8082, smart-tracker:5050, voting-api:18080, voting-webapp:18081, cloudflared (tunnel), watchtower, telegram-docker-bot, github-runners (4x: node-34-telegram/grafana/custom/pinggps), duty-schedule:3002, dev-api:18082, esp-alert, discord-ha

### namespace: monitoring
grafana:3001, prometheus:9090, blackbox-exporter, node-exporter (DaemonSet), cadvisor (DaemonSet), host-db-exporter (DaemonSet, script in ConfigMap)

### namespace: authentik
postgresql, redis, server:9000, worker | data → /var/lib/rancher/k3s/storage/authentik-{database,media,templates}

### namespace: immich
database, redis, machine-learning, server:2283 | data → /opt/immich-app/{library,postgres}, model-cache → K3s storage

### namespace: nextcloud
db (mariadb:10.11), redis, app:8090 | data → /srv/nextcloud/{html,data,db}
⚠️ config.php dbhost must be `db` (K3s service name), not `nextcloud-db`

### namespace: librenms
db, redis, msmtpd, librenms:8000, dispatcher, syslogng, snmptrapd
⚠️ All pods need `enableServiceLinks: false` — K8s injects REDIS_PORT=tcp://... which breaks connections

### namespace: default
registry:5000 | data → /var/lib/rancher/k3s/storage/registry-data

## Cloudflare Tunnel
Config at /etc/cloudflared/config.yml on .34 (root-owned)
All service URLs now use `10.33.1.34` — NOT `127.0.0.1` (cloudflared runs in K3s pod)

## K3s Manifests
~/k3s-manifests/{apps,monitoring,authentik,immich,nextcloud,librenms,registry}/

## Local Registry Images
10.33.1.34:5000 → promptpay-qr-app, smart-tracker, voting-api, voting-webapp, telegram-docker-bot, duty-schedule, dev-api, esp-alert, discord-ha

## GitHub Repos (org: 12MICKY)
telegram_Docker, PING_GPS, Grafana-dashboard-setup, customizecmd

## Local Projects
telegram-docker-bot, customizecmd, Grafana-dashboard-setup, duty-schedule-new, dev-api-upload, discord-ha, esp-alert, Network-tools-, Arduino

**How to apply:** All services are K3s deployments. Use kubectl to manage. Docker Swarm commands no longer applicable.
