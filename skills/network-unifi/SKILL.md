---
name: network-unifi
description: Reference guidelines for UniFi Enterprise Wireless (UEWA), Layer-3 adoption methods, DHCP Option 43, DNS inform, and High-Density AP tuning (Minimum RSSI).
---
# Hardcore UniFi Enterprise Wireless & L3 Adoption Blueprint

This reference manual defines advanced UniFi controller configurations, Layer-3 adoption methods, and wireless network tuning based on Ubiquiti Academy UEWA standards.

---

## 1. Layer-3 Adoption & Provisioning Blueprints
When UniFi Access Points (UAPs) are hosted on different subnets than the UniFi Controller, use one of the following L3 adoption methods:

### Method A: SSH set-inform (CLI Manual)
1. SSH into the factory-default AP (default login: `ubnt`/`ubnt`):
   ```bash
   ssh ubnt@<ap_ip_address>
   ```
2. Trigger the adoption inform URL:
   ```bash
   set-inform http://10.33.1.34:8080/inform
   ```
3. Adopt the device in the UniFi Controller UI.
4. **CRITICAL**: Re-run the `set-inform` command a second time after adoption to finalize the binding:
   ```bash
   set-inform http://10.33.1.34:8080/inform
   ```

### Method B: DNS-Based Adoption (Automated)
Configure the local DNS resolver (e.g. `dnsmasq` on Mikrotik or local DNS server) to resolve the hostname `unifi` to the Controller's IP:
- **Dnsmasq / `/etc/hosts` config**:
  ```hosts
  10.33.1.34  unifi
  ```
APs will automatically query `unifi` on boot and attempt to inform the controller.

### Method C: DHCP Option 43 (Enterprise Automated)
Configure the local DHCP server (Mikrotik RouterOS) to supply the UniFi Controller IP inside the Option 43 block:
```routeros
# Option 43 Hex payload template (Format: 0x0104 + Hex encoded IP Address)
# 10.33.1.34 in hex is 0A 21 01 22
/ip dhcp-server option
add code=43 name=unifi-address value=0x01040a210122

/ip dhcp-server network
set [find address=10.33.1.0/24] dhcp-option=unifi-address
```

---

## 2. High-Density (HD) Wireless Optimization
To prevent airtime hogging and packet drops in environments with high user counts:

### A. Minimum RSSI Tuning
Force clients with poor connections to disassociate, improving cell airtime efficiency.
- **Config**: Set Minimum RSSI to **`-75 dBm`** on UAPs.
- **Result**: AP issues a de-authentication packet (soft-kick) when client signal drops below -75 dBm, encouraging the client to roam to a closer AP.

### B. Band Steering & Airtime Fairness (ATF)
- **Band Steering**: Force dual-band clients onto the 5 GHz band to relieve 2.4 GHz saturation.
- **Airtime Fairness**: Enable ATF in the AP settings to allocate equal transmission time blocks to all clients, preventing legacy 802.11b/g devices from slowing down fast 802.11ac/ax clients.
- **Channel Width**: Keep 5 GHz channel widths at **`20 MHz`** (or max `40 MHz` with clean spectrum) to maximize channel re-use capacity and avoid Co-Channel Interference (CCI).
