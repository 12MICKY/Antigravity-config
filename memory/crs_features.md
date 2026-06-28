---
name: crs-features
description: "CRS MikroTik features enabled/configured — Netwatch, NTP, SNMP, scheduler, DNS, nginx redirects"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4fe9a2bb-d327-4b5c-b886-33b89dc81cb7
---

**CRS features ที่ตั้งค่าแล้ว (2026-05-31)**

## DNS
- `/ip dns static` — .lan entries ครบ 13 entries (grafana/crs/adguard/node1-5/proxmox-node1-5)
- `/ip dns servers` = 10.33.1.47, 1.1.1.1, 8.8.8.8 (AdGuard primary, fallback ถ้า AG ดับ)
- DHCP hands out DNS = 10.33.1.47, 10.33.1.45 (dual-resolver ให้ lab VMs)

## Netwatch (monitor every 30–60s → log warning/info)
- 10.33.1.47 AdGuard — 30s
- 10.33.1.46 Grafana — 30s
- 165.101.64.38 VPS-hub — 60s
- 10.200.0.1 wg-vps tunnel — 30s

## NTP Server
- `/system ntp server` enabled=yes
- ทุก Proxmox node (5 nodes) ใช้ CRS 10.33.1.45 เป็น preferred NTP server ใน chrony
- Verified: `^*10.33.1.45` บนทุก node

## SNMP → Prometheus
- Community: `stemlabs` (read-only, allowed 10.33.1.0/24 + .99.0/25 + 10.9.0.0/24, security=none)
- snmp_exporter v0.21 บน LXC113 — custom `mikrotik` module
- Config: `/etc/prometheus/snmp.yml` (custom module, not if_mib — if_mib timeout เกิน)
- Prometheus job: `snmp_mikrotik` target=10.33.1.45, labels: device=crs, role=router
- Metrics: `ifHCInOctets`, `ifHCOutOctets`, `ifOperStatus`, `ifInErrors`, `ifOutErrors`, `sysUpTime`
  - labels: ifName=ether1/ether2/wg-vps/wg-clients/lo
- **TODO: Grafana dashboard สำหรับ CRS interface traffic**

## Auto-backup Scheduler
- `/system scheduler` name=weekly-backup, interval=7d
- on-event: `/system backup save` + `/export file` ชื่อ auto-<date>
- ไฟล์อยู่ใน /flash/ บน CRS (ดึงออกผ่าน WinBox Files)

## VPN Peer Traffic (manual check)
```
/interface wireguard peers print detail where interface=wg-clients
```
ดู rx/tx/last-handshake ต่อ peer

## nginx port 80 redirects (ติดตั้งบน node + LXC)
- LXC113 (Grafana): nginx proxy port 80 → http://127.0.0.1:3000
  - grafana.lan หรือ grafana → Grafana UI
- node1–5: nginx redirect port 80 → https://node_ip:8006
  - proxmox-node1.lan → https://proxmox-node1.lan:8006 (Proxmox UI)

## DNS Priority fix (laptop)
- NM connection `stemlabs`: `ipv4.dns-search="lan ~."`, `ipv4.dns-priority=-100`
- ทำให้ .lan queries วิ่งผ่าน VPN DNS แทน Chula network DNS

## Pending / TODO
- Grafana dashboard for CRS SNMP metrics (interface in/out, errors)
- Netwatch + email alert (ต้องตั้ง SMTP relay)
- Queue tree สำหรับ limit bandwidth per VPN peer

See also: [[proxmox-cluster]], [[vpn-crs-rbac]], [[infra-servers]]
