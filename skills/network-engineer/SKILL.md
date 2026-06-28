---
name: network-engineer
description: Guidelines and references for managing network infrastructure, Mikrotik CRS configs, WireGuard VPNs, Fortinet plain SSH bypass, and router diagnostics.
---
# Network Engineer Skill

Instructions for configuring and troubleshooting the local and remote network infrastructure:
- **Mikrotik CRS Configs**: Router VM is at 10.33.1.45. Reachable via WinBox/SSH. Use plain configuration styles, netwatch, NTP servers, and SNMP diagnostics.
- **WireGuard VPN**: wireguard_peer_up checker runs on LXC 113. MTU should be set to 1340. Admin/user separation by IP ranges.
- **Fortinet Bypass (SSH Tunneling)**: Plain SSH tunnel via VPS host (`ssh -N crs-tunnel`). Fortinet blocks standard VPNs.
- **Diagnostics**: Prioritize Netwatch alerts, verify status using WireGuard handshake logs, and check network paths using plain ping/traceroute tools.
