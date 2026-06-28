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

## VPN & Network Design Guidelines (Hardcore Topology)

### 1. VLAN Segmentation & Routing Design
- **Subnet Allocation**: Keep clear segregation between Management, Production/K3s, and Client VPN subnets.
- **Inter-VLAN Routing**: Define routing policies on the central Mikrotik switch (or CHR VM). Secure control planes via L3 firewall rules rather than flat VLANs.
- **Dynamic Routing**: Use lightweight OSPF routes for site-to-site VPN networks to automate path redirection on link failover.

### 2. Multi-Tiered VPN Topology
- **Hub-and-Spoke Topology**: Centralize VPN access on the public VPS Host (`165.101.64.45`) acting as the WireGuard hub. Route remote branches (home, lab, client nodes) through this central relay.
- **Site-to-Site WireGuard Tunnels**: Ensure site connections use persistent-keepalive (e.g. 25s) to maintain NAT hole punching. Enforce strict MTU values of `1340` on all tunnel virtual interfaces to avoid packet fragmentation over standard WAN routes.
- **Plain SSH Tunneling Fallback**: For environments restricted by deep packet inspection (DPI) or MITM firewalls (such as Fortinet environments), bypass VPN restrictions using reverse SSH port forwarding routed through a public VPS jump host (`ssh -N -R <port>:localhost:22`).
