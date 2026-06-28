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

---

## 4. Hardcore Production Scripts & Routing Blueprints (RouterOS v7)

### A. Cloudflare Dynamic DNS (v7 http-method PUT API)
Automate IP sync for `home.thiraphat.work` domain behind Cloudflare:
```routeros
/system script
add name=cloudflare-ddns policy=read,write,policy,test,sniff source="
  :local CFToken \"CLOUDFLARE_API_TOKEN\"
  :local CFZone \"CLOUDFLARE_ZONE_ID\"
  :local CFRule \"CLOUDFLARE_RECORD_ID\"
  :local Domain \"home.thiraphat.work\"
  
  :local WANInterface \"ether1\"
  :local CurrentIP [/ip address get [find interface=\$WANInterface] address]
  # Strip subnet mask
  :set CurrentIP [:pick \$CurrentIP 0 [:find \$CurrentIP \"/\"]]
  
  :local ResolveIP [:resolve \$Domain]
  
  :if (\$CurrentIP != \$ResolveIP) do={
    :log info \"CF DDNS: IP mismatch. Updating \$Domain from \$ResolveIP to \$CurrentIP...\"
    /tool fetch http-method=put \
      url=\"https://api.cloudflare.com/client/v4/zones/\$CFZone/dns_records/\$CFRule\" \
      http-header-field=\"Authorization: Bearer \$CFToken,Content-Type: application/json\" \
      http-data=\"{\\\"type\\\":\\\"A\\\",\\\"name\\\":\\\"\$Domain\\\",\\\"content\\\":\\\"\$CurrentIP\\\",\\\"ttl\\\":120}\" \
      output=none
  } else={
    :log info \"CF DDNS: IP is up to date (\$CurrentIP)\"
  }
"
```

### B. Pure Zero-Script Recursive Routing Failover
Configure multi-hop recursive link verification via static host scopes. This bypasses flapping Netwatch scripts:
```routeros
# 1. Virtual host hops via separate ISP gateways
/ip route
add dst-address=8.8.8.8/32 gateway=192.168.1.1 scope=10 check-gateway=ping comment="Link-1 virtual tester"
add dst-address=1.1.1.1/32 gateway=192.168.2.1 scope=10 check-gateway=ping comment="Link-2 virtual tester"

# 2. Main default routes referencing target scopes
add dst-address=0.0.0.0/0 gateway=8.8.8.8 distance=1 target-scope=30 check-gateway=ping comment="Primary Gateway"
add dst-address=0.0.0.0/0 gateway=1.1.1.1 distance=2 target-scope=30 check-gateway=ping comment="Failover Gateway"
```

### C. Webhook Discord Notifications
Directly dispatch status alerts to Discord utilizing RouterOS v7 POST payload fetch:
```routeros
/system script
add name=discord-notify policy=read,write,policy,test source="
  :local webhookUrl \"DISCORD_WEBHOOK_URL\"
  :local msg \"[Mikrotik Alert] Router \$[/system identity get name] backup completed at \$[/system clock get date] \$[/system clock get time]\"
  
  /tool fetch http-method=post \
    url=\$webhookUrl \
    http-header-field=\"Content-Type: application/json\" \
    http-data=\"{\\\"content\\\":\\\"\$msg\\\"}\" \
    output=none
  :log info \"Discord notification sent.\"
"
```
