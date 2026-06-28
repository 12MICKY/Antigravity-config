---
name: snapmaker-u1-printers
description: Two Snapmaker U1 3D printers (Klipper+Moonraker) exposed via stemlabs2.work Cloudflare tunnel — separate domain from thiraphat.work
metadata: 
  node_type: memory
  type: project
  originSessionId: e7eb26e6-4f90-445a-b18b-283ab196623f
---

Thiraphat operates two Snapmaker U1 3D printers managed under the **stemlabs2.work** Cloudflare tunnel (separate from the `thiraphat.work` tunnel listed in [[infra-servers]]).

| Printer | Web/API URL | Moonraker API key |
|---|---|---|
| U1-01 | `u1-01.stemlabs2.work` | `e4ae3bc9308043708cf2b31160176b6e` |
| U1-02 | `u1-02.stemlabs2.work` | `b3a729aadb244493ab0586fc3204008f` |

The hostnames serve **both** the Fluidd web UI (port 80/443 root path) AND the Moonraker JSON API on the same root — authenticate API calls with header `X-Api-Key: <key>`. Without the key Moonraker returns HTTP 401.

The printers are also reachable on Tailscale CGNAT IPs `100.106.78.53` (U1-01) and `100.126.43.89` (U1-02), but Moonraker's default `trusted_clients` does **not** include the `100.64.0.0/10` range, so those IPs hit 401 unless `moonraker.conf [authorization] trusted_clients` is extended.

**Why:** Owned/managed by Thiraphat, distinct domain from his main infra. Likely a school/lab setup (`stemlabs`).

**How to apply:** When Thiraphat mentions "U1", "Snapmaker", "Moonraker", or these hostnames, use the API key + hostname combo rather than the Tailscale IP. The `*-print.stemlabs2.work` subdomains he mentioned (e.g. `u1-01-print.stemlabs2.work`) were planned but **not yet set up in DNS** as of 2026-05-27 — only the bare hostnames resolve.
