---
name: domain-separation
description: thiraphat.work = personal (NOT Stemlabs/CRS project); Stemlabs uses its own domain/VPS
metadata: 
  node_type: memory
  type: project
  originSessionId: 26096605-bf79-4413-915c-b2f5c204f6ff
---

**`thiraphat.work` (Cloudflare tunnel on .34) = personal domain ONLY** — do NOT use it to expose anything for the Stemlabs / Proxmox-CRS project. The user stated it explicitly.

**Stemlabs/CRS project inbound** goes through its own path:
- VPS WireGuard hub 165.101.64.38 (wg0 site-link + wg-easy for people) — primary, beats CU double-NAT.
- If a public URL is ever needed for this project, use a Stemlabs-owned domain (e.g. `stemlabs2.work`, already used for the Snapmaker tunnel), NOT `thiraphat.work`.

**VPS `165.101.64.38` is the WORKPLACE's VPS (ไม่ใช่ของ thiraphat/ส่วนตัว) — clarified 2026-06-02.** Don't host personal things on it (privacy + they could reset/reclaim it). For personal needs (tailscale DERP, personal cloudflared tunnel, .34 failover), Thiraphat plans to buy his OWN VPS. Implication: the whole Stemlabs CRS WireGuard hub currently depends on a workplace-owned box.

**Tailscale routing gotcha (2026-06-02):** from CU (laptop 161.200.x), only `cu-remote-1` (161.200.150.35, advertises 10.33.1.x infra routes via fragmented CIDRs 10.33.1.20/30,24/29,32/28,48/30) connects DIRECT. Everything else — esp. **home pve `homelab`/`pve-homelab` = 10.10.10.10 (LAN 10.10.10.0/24)**, pteachlab, thitiwat — RELAYS via Tailscale **Singapore DERP** (~32ms, bandwidth-capped) because CU net has CaptivePortal + restrictive NAT and home is behind NAT. Fix path = personal VPS in **Thailand** running self-hosted DERP (works regardless of home CGNAT). tailnet owner `thirphathrsricitr9@`.

Related: [[proxmox-cluster]] [[infra-servers]] [[snapmaker-u1-printers]] [[satit-m-fortinet-crs-access]]
