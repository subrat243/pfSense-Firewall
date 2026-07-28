# Interface Assignment & NIC Mapping Guide

## Overview

pfSense relies on FreeBSD network interface drivers. On VirtualBox using Intel PRO/1000 MT Desktop NICs, interfaces are identified as `em0` through `em5`.

---

## Console Interface Assignment Walkthrough

1. From the pfSense console menu, enter option `1` (**Assign Interfaces**).
2. **VLAN Setup**:
   * Prompt: `Should VLANs be set up now [y|n]?`
   * Type `n` and press `Enter`.

3. **WAN Interface Assignment**:
   * Prompt: `Enter the WAN interface name or 'a' for auto-detection:`
   * Type `em0` and press `Enter`.

4. **LAN / Management Interface Assignment**:
   * Prompt: `Enter the LAN interface name or 'a' for auto-detection:`
   * Type `em1` and press `Enter`.

5. **Optional Interfaces Assignment**:
   * Prompt: `Enter the Optional 1 interface name or 'a' for auto-detection:` -> `em2` (Cyber)
   * Prompt: `Enter the Optional 2 interface name or 'a' for auto-detection:` -> `em3` (AD)
   * Prompt: `Enter the Optional 3 interface name or 'a' for auto-detection:` -> `em4` (Security)
   * Prompt: `Enter the Optional 4 interface name or 'a' for auto-detection:` -> `em5` (Malware)
   * Press `Enter` when no additional interfaces remain.

6. **Confirmation**:
   * Review interface summary:
     * WAN -> `em0`
     * LAN -> `em1`
     * OPT1 -> `em2`
     * OPT2 -> `em3`
     * OPT3 -> `em4`
     * OPT4 -> `em5`
   * Type `y` and press `Enter` to commit changes.

---

## WebGUI Renaming & Interface Enablement

After logging into the pfSense WebGUI at `https://10.0.0.1`:

1. Navigate to **Interfaces** -> **Interface Assignments**.
2. Click on **OPT1**, check **Enable Interface**, change IPv4 Configuration Type to **Static IPv4**, change IPv4 Address to `10.10.10.1/24`, and rename description to `CYBER`. Save & Apply.
3. Click on **OPT2**, check **Enable Interface**, change IPv4 Configuration Type to **Static IPv4**, change IPv4 Address to `10.20.20.1/24`, and rename description to `AD`. Save & Apply.
4. Click on **OPT3**, check **Enable Interface**, change IPv4 Configuration Type to **Static IPv4**, change IPv4 Address to `10.30.30.1/24`, and rename description to `SECURITY`. Save & Apply.
5. Click on **OPT4**, check **Enable Interface**, change IPv4 Configuration Type to **Static IPv4**, change IPv4 Address to `10.40.40.1/24`, and rename description to `MALWARE`. Save & Apply.

---

## Console IP Configuration for Management (LAN / `em1`)

To configure the initial Management IP from console:
1. Select Console Option `2` (**Set interface(s) IP address**).
2. Select interface index for `LAN` (`em1`).
3. Enter new IPv4 address: `10.0.0.1`
4. Enter IPv4 subnet mask bit count: `24`
5. For WAN gateway on LAN, press `Enter` (None).
6. Enter `y` to enable DHCP server on LAN.
7. Enter start address: `10.0.0.100`, end address: `10.0.0.200`.
8. Do not revert to HTTP (keep HTTPS).
