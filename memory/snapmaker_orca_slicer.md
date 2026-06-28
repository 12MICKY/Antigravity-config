---
name: snapmaker-orca-slicer
description: Slicer สำหรับ Snapmaker U1 บน laptop — ใช้ Snapmaker Orca AppImage (flatpak OrcaSlicer เด้งเพราะ webkit)
metadata: 
  node_type: memory
  type: project
  originSessionId: ee057cbc-b332-4679-9ae6-9dd4ae244d00
---

**⚠️ สถานะ 2026-06-04: ลบ slicer ออกจาก laptop หมดแล้วทั้ง 2 ตัว** (Snapmaker Orca AppImage + OrcaSlicer flatpak + data/config/overrides). ตอนนี้เครื่องไม่มี slicer. ด้านล่างคือบทเรียน/วิธีลงเผื่อต้องการกลับมาลงใหม่.

**Snapmaker Orca** (OrcaSlicer fork ทางการของ Snapmaker, tuned สำหรับ U1) = slicer ที่ใช้บน laptop. ติดตั้งเป็น **AppImage** ที่ `~/Applications/Snapmaker_Orca.AppImage` (+ desktop entry `~/.local/share/applications/snapmaker-orca.desktop`, ไอคอนในเมนูชื่อ "Snapmaker Orca"). ดาวน์โหลด build `Snapmaker_Orca_Linux_ubuntu_2404_V*.zip` จาก GitHub releases `Snapmaker/OrcaSlicer` (อย่าเอา flatpak.zip).

- **ทำไมไม่ใช้ flatpak `com.orcaslicer.OrcaSlicer`:** flatpak ลงไว้ก่อนแล้วมัน **segfault ใน libwebkit2gtk-4.1.so.0.21.7 (webkitgtk 2.44)** ตอนเปิดหน้า login/hub → ลากทั้งแอปปิด ("ตัด"). เครื่องนี้ Intel Raptor Lake UHD + Mesa 25.2.8 บน Wayland. ลอง flatpak override env (`GDK_BACKEND=x11`, `WEBKIT_DISABLE_DMABUF_RENDERER=1`, `WEBKIT_DISABLE_COMPOSITING_MODE=1`, `DRI_PRIME=0`, `WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1`) → ช่วยให้ webview crash ไม่ลากแอปหลักตาย แต่ webkit **ยัง segfault อยู่ดี**. flatpak ลาก webkit 2.44 มาเองในตัว runtime แก้ไม่ได้.
- **วิธีที่หาย crash จริง = AppImage native** ที่ใช้ **libwebkit2gtk-4.1 ของระบบ = 2.52.3** (ใหม่กว่ามาก ไม่บั๊กกับ Mesa เครื่องนี้). เทสต์รัน 40s, segfault = 0. host มี `libwebkit2gtk-4.1-0` + libfuse2 อยู่แล้ว.
- flatpak ตัวเก่ายังอยู่ (ไม่ได้ลบ) — ถ้าจะเอาออก: `flatpak uninstall --user com.orcaslicer.OrcaSlicer -y`.
- Printer: 2× Snapmaker U1 (ดู [[snapmaker-u1-printers]]).
