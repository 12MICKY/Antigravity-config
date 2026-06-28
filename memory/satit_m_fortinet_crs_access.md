---
name: satit-m-fortinet-crs-access
description: Satit-M (ที่ทำงาน) เน็ต Fortinet บล็อก VPN/tunnel ทุกแบบ — วิธีเข้า CRS/lab จากเน็ตนี้คือ plain SSH ผ่าน VPS host
metadata: 
  node_type: memory
  type: project
  originSessionId: ba64f184-dbb1-4e71-a5e7-6a5488eb0b63
---

**เน็ต Satit-M (ที่ทำงาน, laptop ได้ IP 10.9.x.x/21, gw 10.9.0.1) = Fortinet firewall ที่บล็อก tunnel ทุกแบบ** (เจอ 2026-06-02). อะไรใช้ได้/ไม่ได้บนเน็ตนี้:

- ❌ **wg `stemlabs` VPN** — handshake ขึ้นแต่ไม่มี data กลับ (laptop รับแค่ 92B). สาเหตุ: Fortinet ทำ **symmetric NAT** สลับ source port → CRS wg-clients peer "thiraphat" จำ endpoint เก่าค้าง (last-handshake ไม่ complete) ส่ง reply ไป port ที่ตายแล้ว. saral ใช้ได้เพราะอยู่เน็ตบ้าน. ดู [[vpn-crs-rbac]].
- ❌ **Tailscale** — Fortinet MITM HTTPS → `x509: certificate signed by unknown authority` login ไม่ได้.
- ❌ **Cloudflare `cloudflared access tcp`** (TCP/WebSocket tunnel) — Fortinet **reset connection ที่ :443** (`crs-ssh.thiraphat.work` reset, แต่ `grafana.thiraphat.work` HTTP ปกติ = 302 ผ่าน). ทดสอบชื่อกลางๆ (`relay-a7`) ก็ reset → ไม่ใช่กรองตามชื่อ แต่บล็อก tunnel-over-HTTPS. **ฝั่ง Cloudflare ถูกหมด** (จาก VPS ที่ไม่มี Fortinet → `crs-ssh.thiraphat.work` ตอบ 200).
- ✅ **Plain SSH ออก public IP** = สิ่งเดียวที่ผ่าน Fortinet.

**วิธีเข้า CRS/lab จาก Satit-M (ใช้ได้จริง):** SSH tunnel ชั้นเดียวผ่าน **VPS host** (165.101.64.38:22, key auth) — VPS host เข้า CRS 10.33.1.45:22/8291 ตรงผ่าน wg1 ได้ (src 10.200.0.1 อยู่ใน CRS mgmt allow-list 10.200.0.0/24). ตั้ง alias ใน `~/.ssh/config` ชื่อ `crs-tunnel` แล้ว:
```
ssh -N crs-tunnel        # เปิดทิ้งใน terminal ตัวเอง
# WinBox -> 127.0.0.1:18291 ; SSH -> ssh -p 10022 admin@127.0.0.1 (admin/Yaimakmak888)
```
หมายเหตุ: harness (Claude Code) ถือ tunnel ค้างเองไม่ได้ — process โดน SIGTERM (exit 144) หลังจบ command ทุกครั้ง → ต้องให้ user รัน command ใน terminal เอง.

**Cloudflare CRS routes บน .34 (thiraphat.work tunnel):** เพิ่ม `crs-ssh.thiraphat.work` → `tcp://10.33.1.45:22` + `crs-winbox.thiraphat.work` → `tcp://10.33.1.45:8291` ใน ConfigMap `cloudflared-config` (ns apps). **ใช้ได้จากเน็ตที่ไม่มี Fortinet** (บ้าน/มือถือ) ด้วย `cloudflared access tcp --hostname crs-ssh.thiraphat.work --url 127.0.0.1:PORT`. ⚠️ **ยังไม่ได้ตั้ง Cloudflare Access** (ไม่มี CF API token บน .34/laptop) — ใครรู้ hostname ก็เข้าได้ (ยังต้องมี CRS cred) ควรตั้ง Access ที่ dashboard. ข้อนี้ขัด domain-separation (ดู [[domain-separation]]) — ทางเลือกสะอาดกว่าคือย้ายไป stemlabs2.work tunnel (ct116, [[ct116-cloudflare-tunnel]]).

See [[infra-servers]], [[stemlabs-vps-vm]], [[proxmox-cluster]].
