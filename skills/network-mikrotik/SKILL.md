---
name: network-mikrotik
description: Hardcore reference blueprints for Thiraphat's Mikrotik CRS switch and RouterOS (v6/v7) configurations, firewall filters, and Netwatch scripts.
---
# Hardcore RouterOS Configuration & Operations

This reference skill defines RouterOS v7 setups specifically tailored for Thiraphat's Mikrotik CRS switch (`10.33.1.45`).

---

## 1. Bridge VLAN Filtering (Hardware Offloaded)
Ensure all L2 switched ports use Bridge VLAN Filtering to secure VLAN 10 (Prod/Management) and VLAN 20 (Dev/Guest).

```routeros
# 1. Initialize Bridge with VLAN filtering enabled
/interface bridge
add name=bridge1 vlan-filtering=yes comment="Hardware offloaded CRS bridge"

# 2. Assign Physical Interfaces
# Trunk port connecting to hypervisors: sfp-sfpplus1
# Access ports: ether1 to ether24
/interface bridge port
add bridge=bridge1 interface=ether1 pvid=10 comment="Prod Server (.34)"
add bridge=bridge1 interface=ether2 pvid=10 comment="Dev Server (.32)"
add bridge=bridge1 interface=ether3 pvid=20 comment="Lab VM 102 (.24)"
add bridge=bridge1 interface=sfp-sfpplus1 comment="Trunk Port to PVE Hosts"

# 3. Define VLAN mappings
/interface bridge vlan
add bridge=bridge1 tagged=bridge1,sfp-sfpplus1 untagged=ether1,ether2 vlan-ids=10
add bridge=bridge1 tagged=bridge1,sfp-sfpplus1 untagged=ether3 vlan-ids=20

# 4. Initialize L3 interfaces for routing
/interface vlan
add interface=bridge1 name=vlan10 vlan-id=10
add interface=bridge1 name=vlan20 vlan-id=20

/ip address
add address=10.33.1.45/24 interface=vlan10 network=10.33.1.0
```

---

## 2. WireGuard Site-to-Site configuration
RouterOS v7 config linking the CRS switch to the public personal VPS hub (`165.101.64.45`).

```routeros
# 1. Create WireGuard Interface
/interface wireguard
add listen-port=51820 mtu=1340 name=wg1 comment="Site-to-Site Tunnel to VPS Hub"

# 2. Assign IP Address (MTU 1340)
/ip address
add address=10.10.10.45/24 interface=wg1 network=10.10.10.0

# 3. Add public VPS Peer
/interface wireguard peers
add interface=wg1 public-key="Personal_VPS_Hub_Public_Key" \
    endpoint-address=165.101.64.45 endpoint-port=51822 \
    allowed-address=10.10.10.0/24,10.20.20.0/24,10.10.11.0/24 \
    persistent-keepalive=25s comment="VPS Hub Relay"
```

---

## 3. Netwatch & Script Automation
Automate host status logging, weekly backups, and sync triggers on the CRS switch.

### WireGuard Peer Metrics Checker (LXC 113):
This script runs on LXC 113 to monitor WG peers handshake times. If the last handshake exceeds 180s, trigger alert.
On Mikrotik, monitor the LXC 113 status:
```routeros
/tool netwatch
add host=10.33.1.113 interval=30s timeout=2s \
    up-script=":log info \"WG metrics exporter LXC 113 is UP\"" \
    down-script=":log warning \"WG metrics exporter LXC 113 is DOWN! Checking ping route...\""
```

### Auto Weekly Backup & Configuration Export:
```routeros
/system script
add name=auto-backup source="
  :local sysname [/system identity get name]
  :local date [/system clock get date]
  :local time [/system clock get time]
  # Format date to filename friendly
  :local cleanDate ([:pick \$date 7 11] . \"-\" . [:pick \$date 0 3] . \"-\" . [:pick \$date 4 6])
  :local cleanTime ([:pick \$time 0 2] . \"-\" . [:pick \$time 3 5])
  :local backupName (\$sysname . \"-\" . \$cleanDate . \"-\" . \$cleanTime)
  
  /system backup save name=\$backupName
  /export file=\$backupName
  :log info \"Mikrotik Backup and Config Export saved as \$backupName\"
"

# Scheduler to trigger script every Sunday at 03:00 AM
/system scheduler
add name=weekly-backup-scheduler interval=7d start-date=jun/28/2026 start-time=03:00:00 on-event=auto-backup
```
