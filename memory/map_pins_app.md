---
name: map-pins-app
description: "map.thiraphat.work — shared map-pins web app (Leaflet + Node) on .34, drop pins with photo/text"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1200e314-886f-463e-811e-f806ac3012da
---

**map.thiraphat.work** — เว็บแอปแผนที่ปักหมุดร่วมกัน (shared) สร้าง 2026-06-09.

- Source: `~/Projects/map-pins` (Node/Express + Leaflet/OpenStreetMap, no API key)
- Single container serves both frontend + `/api` + uploaded images
- Frontend: `public/index.html` (mobile-first, ใช้ GPS มือถือ, แตะแผนที่ปักหมุด, แนบรูป/พิมพ์ข้อความ)
- API: `GET/POST/DELETE /api/markers`, รูปเก็บที่ `/uploads`
- Storage: JSON file + รูปบนดิสก์ ใน **PVC `map-pins-data`** (local-path) → `/data`
- On .34: **K3s Deployment `map-pins` ns `apps`** (migrated off raw docker 2026-06-10), image `10.33.1.34:5000/map-pins:latest`, Service NodePort **18091**, manifest `~/k3s-manifests/apps/map-pins.yaml`. Old bind dir `/home/thiraphat/map-pins-data` on .34 kept as backup copy.
- Tunnel: ConfigMap `cloudflared-config` entry `map.thiraphat.work → http://10.33.1.34:18091` (unchanged — NodePort matches old docker port) + CNAME ผ่าน CF API
- GitHub: `12MICKY/map-pins` (private)

เกี่ยวข้อง: [[infra_servers]] [[workflow_patterns]]
