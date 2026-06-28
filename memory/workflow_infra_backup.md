---
name: workflow-infra-backup
description: "Workflow สำหรับ infra backup, config files, documentation — ที่เก็บ, server แต่ละตัวมีบทบาทอะไร"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 4fe9a2bb-d327-4b5c-b886-33b89dc81cb7
---

## กฎการเก็บไฟล์ infra/backup

**Backup + Config ไฟล์ที่เกี่ยวกับ Proxmox/CRS:**
→ เก็บที่ **Proxmox node5** `root@10.33.1.44:/root/chr-proxmox/`
→ ห้ามเก็บไว้บนเครื่อง local หรือ .34

**Why:** node5 เป็น Proxmox gateway + มี CRS license cron อยู่แล้ว — เหมาะเป็น infra management node

**Documentation/Map:**
→ เขียนเป็น Markdown + Mermaid diagram แล้ว push GitHub **private repo** (org: 12MICKY)
→ ตัวอย่าง: `stemlabs-network-map` repo

## บทบาทของแต่ละ server

| Server | IP | บทบาท | เก็บอะไร |
|---|---|---|---|
| **local ThinkBook** | — | เครื่องทำงาน (เครื่องที่คุยกับ Claude) | ไม่เก็บอะไรถาวร — copy ขึ้น server เสมอ |
| **.34** | 10.33.1.34 | **Personal server ของ Thiraphat** + K3s prod | user-facing services, personal tools |
| **.32** | 10.33.1.32 | K3s dev/worker | ทดลอง, throwaway |
| **node5** | 10.33.1.44 | Proxmox gateway + infra mgmt | CRS backup, config, NOTE.md, grafana configs |
| **node1** | 10.33.1.20 | CRS host (Intel NIC) | CRS VM (HA) |

## Workflow ทั่วไป

1. ทดสอบ/ตั้งค่า → verify live (ping, DHCP, curl) → แน่ใจแล้วค่อย document
2. Document → Markdown + Mermaid บน GitHub private repo
3. Config/backup → SCP ขึ้น node5 ทันที ลบออกจาก local
4. ถ้าเป็น Proxmox infra → เก็บบน node5; ถ้าเป็น personal tool → เก็บบน .34
5. GitHub repo ทุกตัวที่เกี่ยวกับ infra → **private** (org: 12MICKY)

**Why:** ไม่อยากมีไฟล์กระจาย หาไม่เจอ — เก็บที่เดียวต่อหมวด

See also: [[infra-servers]], [[proxmox-cluster]]
