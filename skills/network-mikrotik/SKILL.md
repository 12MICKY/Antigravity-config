---
name: network-mikrotik
description: Hardcore reference guidelines for MikroTik RouterOS (v6/v7) configurations, Bridge VLAN filtering, firewall rules, Netwatch script automation, and WireGuard VPNs.
---
# Hardcore MikroTik RouterOS Configuration & Operations Guide

This guide defines elite-level RouterOS (v6/v7) configuration templates, performance optimizations, and automation scripting for Mikrotik CRS and VM instances.

---

## 1. Bridge VLAN Filtering (Hardware Offloaded)
Always configure VLANs using Bridge VLAN Filtering to ensure hardware offloading (L2 HW Offload) on CRS switches. Do not use multiple bridges or legacy VLAN interface configurations.

### Configuration Template:
```routeros
# 1. Create a bridge and enable vlan-filtering
/interface bridge
add name=bridge1 vlan-filtering=yes comment="Hardware offloaded bridge"

# 2. Add member ports to the bridge
/interface bridge port
add bridge=bridge1 interface=ether1 pvid=10 comment="Access Port (VLAN 10)"
add bridge=bridge1 interface=ether2 pvid=20 comment="Access Port (VLAN 20)"
add bridge=bridge1 interface=ether3 comment="Trunk Port (VLAN 10,20)"

# 3. Configure VLAN tagging/untagging on the bridge
/interface bridge vlan
add bridge=bridge1 tagged=bridge1,ether3 untagged=ether1 vlan-ids=10
add bridge=bridge1 tagged=bridge1,ether3 untagged=ether2 vlan-ids=20

# 4. Create VLAN interfaces on top of the bridge for L3 routing
/interface vlan
add interface=bridge1 name=vlan10 vlan-id=10
add interface=bridge1 name=vlan20 vlan-id=20
```

---

## 2. Hardened Firewall Rules (RouterOS v7)
Always place FastTrack at the top of the filter rules to bypass the connection tracking engine for established traffic, maximizing throughput.

```routeros
# Address list configuration for management
/ip firewall address-list
add address=10.33.1.0/24 list=admin-access

# Hardened firewall rules filter
/ip firewall filter
add action=accept chain=input connection-state=established,related,untracked
add action=drop chain=input connection-state=invalid
add action=accept chain=input protocol=icmp comment="Allow ping"
add action=accept chain=input src-address-list=admin-access comment="Allow Admin WinBox/SSH"
add action=drop chain=input comment="Drop all other input traffic"

add action=fasttrack-connection chain=forward connection-state=established,related comment="FastTrack established/related"
add action=accept chain=forward connection-state=established,related,untracked
add action=drop chain=forward connection-state=invalid
add action=accept chain=forward out-interface-list=WAN comment="Allow LAN to WAN"
add action=drop chain=forward comment="Drop all other forward traffic"
```

---

## 3. WireGuard VPN Topology (CRS & VPS)
Configure WireGuard on RouterOS v7 for secure site-to-site and client-to-site topologies.

```routeros
# 1. Create WireGuard Interface
/interface wireguard
add listen-port=51820 mtu=1340 name=wg0 comment="WireGuard interface (MTU 1340)"

# 2. Assign IP Address to WireGuard Interface
/ip address
add address=10.10.10.1/24 interface=wg0 network=10.10.10.0

# 3. Configure Peers
/interface wireguard peers
add interface=wg0 public-key="PEER_PUBLIC_KEY" allowed-address=10.10.10.2/32 comment="Admin laptop"
add interface=wg0 public-key="VPS_PUBLIC_KEY" endpoint-address="165.101.64.45" endpoint-port=51822 allowed-address=10.20.20.0/24 comment="VPS peer"
```

---

## 4. Netwatch & Script Automation
Automate link failover and weekly backups using Netwatch and RouterOS scripting.

### Netwatch Failover:
```routeros
/tool netwatch
add host=8.8.8.8 interval=10s timeout=1s \
    up-script="/ip route set [find comment=\"primary-wan\"] disabled=no" \
    down-script="/ip route set [find comment=\"primary-wan\"] disabled=yes"
```

### Automated Weekly Backup Script:
```routeros
/system script
add name=weekly-backup source="
  :local filename ([/system identity get name] . \"-\" . [:pick [/system clock get date] 0 3] . [:pick [/system clock get date] 4 6] . [:pick [/system clock get date] 7 11])
  /system backup save name=\$filename
  /export file=\$filename
  :log info \"System backup and configuration export saved as \$filename\"
"
```
