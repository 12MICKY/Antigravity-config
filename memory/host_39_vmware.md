---
name: host-39-vmware
description: "10.33.1.39 = VMware VM at Satit-M (behind Fortinet, no internet), wiped to clean base Ubuntu + stemlab user"
metadata: 
  node_type: memory
  type: project
  originSessionId: be00c66d-9e76-4d15-9b72-9dfd34708111
---

**10.33.1.39** — a **VMware VM** (NIC MAC 00:50:56:8b:4c:04, iface `ens33`) on the Satit-M LAN, NOT a Proxmox guest. I only have SSH access into the guest (no VMware host access → can't reimage/redeploy, only in-guest changes).

- **Login: `ssh stemlab@10.33.1.39` / pw `Yaimakmak8888`** (sudo). Created 2026-06-03; old users pillsync/secureuser/thiraphat were all deleted.
- **2026-06-03 wiped to "clean base Ubuntu Server" in-place over SSH:** removed NetBox (/opt/netbox), Home Assistant, Mosquitto MQTT, MongoDB, nginx, apache2, Cockpit (was on :9090), certbot, open-iscsi + their data/config; deleted all human users except stemlab; cleared failed units. Result: only `:22` ssh + local systemd-resolved listening; remaining services are base Ubuntu (cloud-init/snapd/ufw/open-vm-tools). Tailscale also fully purged earlier.
- **No internet egress** — the Satit-M **Fortinet gateway (gw 10.33.1.1, MAC 48:a9:8a:6f:f9:d9)** intercepts/blocks: UDP53 DNS works (resolves fine, incl via cluster AdGuard 10.33.1.47) but ICMP + TCP53 blocked, and TLS is SSL-inspected (tailscale saw cert `*.satitm.chula.ac.th` instead of the real cert → proof of Fortinet MITM). Changing DNS does NOT fix it — block is at firewall/TLS layer, not DNS. LAN/same-subnet TCP works (reached 10.33.1.34:22). To get internet out: register MAC at the Fortinet, or tunnel via VPS over plain SSH:22 (see [[satit-m-fortinet-crs-access]]).

Related: [[satit-m-fortinet-crs-access]], [[infra-servers]]
