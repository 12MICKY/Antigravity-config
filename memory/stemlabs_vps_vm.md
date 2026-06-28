---
name: stemlabs-vps-vm
description: "VM 102 stemlabs-vps on Proxmox — uses VPS public IP via WireGuard, full config + the dual-tunnel architecture on VPS"
metadata: 
  node_type: memory
  type: project
  originSessionId: ee3b92f3-d794-4813-bf60-189f7f591e18
---

**VM 102 "stemlabs-vps"** — สร้างบน Proxmox cluster (10.33.1.21 = node, root pw `Yaimakmak888`) เพื่อใช้ public IP ของ VPS ออกเน็ต (งานที่ทำงาน เน็ต Chula เป็น captive portal).

## Specs
- LAN IP `10.33.1.24` · **Public IP `165.101.64.38`** (ผ่าน WireGuard ไป VPS)
- 4 cores (cpu=host), RAM 10GB (balloon 512MB–10GB), Disk 120GB (ssd+discard+writeback+iothread), onboot+guest-agent
- OS Ubuntu 22.04, shell zsh + [[project-overview]] customizecmd (linux-server) ทุก user

## Access
- **SSH นอก:** `ssh root@165.101.64.38 -p 2222` (VPS forward :2222 → VM:22)
- root pw `bOqsP6rC7!YFC` (no sudo) · thiraphat pw `TydzI33@%X5o3` (sudo) · saral pw `Saral2024!` (sudo, ถูกบังคับเปลี่ยนตอน login แรก)
- โควต้าแยกคนละ 50GB ผ่าน loop filesystem (`/home-thiraphat.img`, `/home-saral.img` sparse) — home 700 แยกกันสนิท
- DNS resolver: 10.33.1.47 (internal .lan) + 8.8.8.8 + 1.1.1.1 (คุมที่ wg0.conf DNS=)
- NTP: clock.nectec.or.th (NECTEC ไทย), timezone Asia/Bangkok

## ⚠️ VPS 165.101.64.38 = dual WireGuard tunnel (อย่าสับสน!)
- **wg0 port 51821** = stemlabs VM tunnel (peer = VM)
- **wg1 port 51820** = CRS site-link ([[vpn-crs-rbac]]) — DNAT :51822→CRS + SNAT 10.200.0.1 + route 10.33.1.0/24 dev wg1, AllowedIPs รวม 10.33.1.0/24
- **บทเรียน:** ตอนแรกเขียนทับ `/etc/wireguard/wg0.conf` ที่เป็น CRS tunnel → CRS VPN ล่มทั้งระบบ ทุก client ต่อไม่ได้ แก้โดยแยกเป็น wg0/wg1 คนละ port คนละไฟล์
- internet ของ VM วิ่งผ่าน NAT ของ node .21 (captive portal workaround) — ถ้า .21 reboot/logout VM ออกเน็ตชั่วคราวไม่ได้ แต่ CRS ไม่กระทบ

## Capacity (ผู้ใช้จะกลับมาถามเรื่องขยาย)
- ปัจจุบันใช้ 3% (root 2.6G/120G). home img เป็น sparse โตตามใช้จริง
- เต็มสุด 2×50GB + OS = ~103GB บน 120GB → พอ เหลือ ~17GB
- ถ้าจะให้ user เกิน 50GB หรือลง service หนักบน root → ค่อยขยาย disk + loop fs (live ได้)

## ⚠️ GOTCHA: ทุก user เข้า :2222 ไม่ได้พร้อมกัน = fail2ban แบน gateway (เจอ+แก้ 2026-06-02)
- VPS มี `iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE` → ทุก connection ที่ forward จาก :2222 (DNAT→10.100.0.2:22) ถูก SNAT เป็น **source เดียว 10.100.0.1** (VPS wg0 IP) เมื่อถึง VM
- VM รัน **ufw (INPUT policy DROP) + fail2ban (chain f2b-sshd)**. พอใครล็อกอินพลาดครบ → fail2ban แบน 10.100.0.1 → REJECT icmp-port-unreachable = **"Connection refused" และล็อกทุกคนพร้อมกัน** (เพราะ source เดียวกันหมด)
- อาการวินิจฉัย: VM `qm status`=running, sshd ผูก 0.0.0.0:22, ทดสอบ local/LAN .24:22 ผ่าน แต่ VPS-local `nc 10.100.0.2 22`=refused, ping ผ่าน → ชี้ fail2ban. เช็ค `iptables -S f2b-sshd` เห็น `-s 10.100.0.1/32 -j REJECT`
- **แก้ถาวร:** `/etc/fail2ban/jail.d/ignore-vps-gateway.conf` = `[DEFAULT]\nignoreip = 127.0.0.1/8 ::1 10.100.0.0/24 10.33.1.0/24` + `systemctl restart fail2ban`. Brute-force ป้องกันที่ fail2ban ของ VPS เอง (เห็น IP จริง). ปลดแบนเฉพาะหน้า: `fail2ban-client set sshd unbanip 10.100.0.1`
- เขียน config อย่าใช้ `echo PW | sudo -S tee file <<EOF` — heredoc แย่ง stdin ทำ password หลุดลงไฟล์ + service ไม่ start. ใช้ write /tmp ด้วย user ปกติ แล้ว `sudo cp`
- VM host key เปลี่ยน (sshd เคย reinstall/restart) → laptop ต้อง `ssh-keygen -R 10.33.1.24` ก่อนเข้า LAN

## ค้าง
- codex SSH key (`codex-remote-admin`) ลบจาก VM แล้ว แต่ยังอยู่บน Proxmox cluster `/etc/pve/priv/authorized_keys` (ทุก node) — ผู้ใช้ยังไม่ตัดสินใจว่าจะลบ cluster-wide ไหม
