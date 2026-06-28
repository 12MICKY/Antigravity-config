---
name: crs-license-free-decision
description: Open decision — how to make the Stemlabs CRS router license-free (CHR free vs trial-autorenew vs VyOS/OPNsense migration)
metadata: 
  node_type: memory
  type: project
  originSessionId: 77fbc0a2-d709-4ff3-ad17-bdb0d202d217
---

**OPEN DECISION (raised 2026-05-30, user will come back to choose):** how to run the Stemlabs CRS router for free without the license-renew hassle. Currently on CHR p-unlimited **trial + auto-renew from node5** (full speed, $0, but keeps a secret — see [[proxmox-cluster]]).

Three free paths presented:
1. **CHR free license** (`/system license renew level=free`) — $0, no renew, no secret, but **capped 1 Mbit/s per interface** (chokes ether1 WAN → all NAT/wg/VPN traffic throttled). OK only if the 10.33.99.x LAN carries near-zero load.
2. **Trial + auto-renew** (current state) — $0, full speed, but needs the renew automation + account pw stored on node5.
3. **Migrate router OS to a license-free platform** — $0, full speed, no cap, no renew, no secret. Options: **VyOS** (CLI, lightweight) or **OPNsense** (web UI). Does NAT/DHCP/WireGuard/DNS like the CHR. Requires rebuilding the config on a new VM (net0→vmbr0 WAN, net1→crslan LAN), then cutover. **This is the recommended "free + full speed + no secret" answer.**

When user returns: ask which path; if path 3, ask VyOS vs OPNsense and then do the migration (replicate the hardened CHR config — see [[proxmox-cluster]] §2 for current firewall/NAT/DHCP/wg-vps/DNS setup).

**UPDATE 2026-05-30 — user leaning toward BUYING a CHR license (paid path), parked again ("will come back").** KEY: do NOT buy p-unlimited $250 — node NICs are only 1GbE, so **CHR `p1` = $45 (~1,530฿ @34฿/$) is enough** (1 Gbit/s per interface = matches the 1GbE ceiling, perpetual, no renew, no secret). Tiers: p1 $45 (1G/iface), p10 $95 (10G/iface), p-unlimited $250 (∞). Hardware alt if they want a box independent of the cluster: MikroTik RB5009 ~6,000–7,500฿.
- **How to buy p1:** log in mikrotik.com (acct `thirphathrsricitr9@gmail.com` / pw `8aD7K1brMW`), Make a new purchase → CHR → level p1 → system-id `eQ5AW3Km+0P` → pay card/PayPal. (WebFig on CRS is disabled, so use web account or WinBox System→License→Renew; needs a payment method on the account — Claude can't pay.)
- **After user says "bought/installed", Claude finishes:** `/system license renew account=... level=p1` to pull it; verify `/system license print` shows level p1 + no deadline (perpetual); then DELETE the node5 auto-renew (`crontab -r` line, `/root/crs-license-renew.sh`, `/root/.crs-account`) so no secret/renew remains. That closes item 1 cleanly.
