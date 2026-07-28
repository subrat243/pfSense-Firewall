# pfSense Troubleshooting & Diagnostic Guide

## Overview

This guide lists common operational issues encountered during pfSense VirtualBox deployment, interface assignments, packet routing, DNS resolution, and their verified solutions.

---

## Troubleshooting Matrix

### Issue 1: Unable to Access pfSense WebGUI at `https://10.0.0.1`

* **Symptom**: Web browser timeout when accessing `https://10.0.0.1`.
* **Root Causes & Diagnostics**:
  1. Client VM is attached to incorrect VirtualBox Internal Network.
  2. Client VM IP address is outside `10.0.0.0/24`.
  3. Anti-lockout rule was accidentally removed from LAN interface.
* **Resolution**:
  1. Check VirtualBox VM network settings -> ensure Adapter is set to `Internal Network` -> `intnet-mgmt`.
  2. Inspect client IP: `ip a` or `ipconfig /all`. Request new DHCP lease (`dhclient` or `ipconfig /renew`).
  3. From pfSense console, run Option `11` (**Restart webConfigurator**) or Option `2` (**Set interface IP address**) to re-enable WebGUI and anti-lockout rule.

---

### Issue 2: WAN Interface Has No IP Address (`0.0.0.0` or Missing Gateway)

* **Symptom**: WAN shows `v4/DHCP: 0.0.0.0` on console or no default gateway.
* **Root Cause**: VirtualBox Adapter 1 NAT network driver disconnected or VirtualBox NAT network backend stalled.
* **Resolution**:
  1. Go to VirtualBox VM Settings -> Network -> Adapter 1 (NAT) -> Ensure **Cable Connected** checkbox is ticked.
  2. From pfSense console, open Shell (Option `8`) and run:
     ```bash
     dhclient em0
     ```

---

### Issue 3: No Outbound Internet Egress from Internal Subnets

* **Symptom**: Internal hosts can ping pfSense gateway `10.x.x.1`, but cannot ping `8.8.8.8` or reach external websites.
* **Root Cause**: Outbound NAT rule missing for subnets, or default gateway down.
* **Resolution**:
  1. Log into WebGUI -> Navigate to **Status** -> **Gateways**. Confirm `WAN_DHCP` status is `Online`.
  2. Navigate to **Firewall** -> **NAT** -> **Outbound**. Ensure Mode is set to **Automatic** or **Hybrid**, and rules exist covering `10.0.0.0/8`.

---

### Issue 4: Inter-VLAN Traffic Blocked Unintentionally

* **Symptom**: Host in Management cannot reach Active Directory DC `10.20.20.10`.
* **Root Cause**: Firewall rule ordering or missing state creation.
* **Resolution**:
  1. Inspect **Firewall** -> **Rules** -> **LAN**. Ensure pass rules for `Internal_Lab_Subnets` are located **ABOVE** any block rules.
  2. Inspect pfSense States: Go to **Diagnostics** -> **States**, search for target IP `10.20.20.10` and kill stale states.

---

### Issue 5: DNS Resolution Fails on Internal Hosts

* **Symptom**: Host can ping `1.1.1.1` by IP address, but `nslookup google.com` fails.
* **Root Cause**: Unbound DNS service stopped or interface binding restricted.
* **Resolution**:
  1. Go to **Services** -> **DNS Resolver**. Verify service status icon is green (Running).
  2. Under **Network Interfaces**, select **All** to ensure Unbound responds on all internal subnets.
