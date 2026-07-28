# Dynamic Host Configuration Protocol (DHCP) Scopes

## Overview

pfSense acts as the central DHCP Server for all internal subnets. This document specifies the active scopes, lease durations, DNS options, and static DHCP reservations.

---

## Global DHCP Settings

* **Lease Duration**: Default 7200 seconds (2 hours), Maximum 86400 seconds (24 hours).
* **DNS Servers Offered**: Gateway IP (`x.x.x.1`) pointing to pfSense Unbound DNS Resolver.
* **Domain Name**: `lab.local` (except AD network which uses `corp.local`).

---

## Detailed DHCP Scope Configuration

### 1. Management Subnet (`em1` / LAN)
* **Status**: Enabled
* **Subnet**: `10.0.0.0/24`
* **Subnet Mask**: `255.255.255.0`
* **Available Range**: `10.0.0.100` to `10.0.0.200`
* **WINS / DNS**: Offered DNS = `10.0.0.1`

### 2. Cyber Range Subnet (`em2` / CYBER)
* **Status**: Enabled
* **Subnet**: `10.10.10.0/24`
* **Subnet Mask**: `255.255.255.0`
* **Available Range**: `10.10.10.100` to `10.10.10.200`
* **Offered DNS**: `10.10.10.1`

### 3. Active Directory Subnet (`em3` / AD)
* **Status**: Enabled
* **Subnet**: `10.20.20.0/24`
* **Subnet Mask**: `255.255.255.0`
* **Available Range**: `10.20.20.100` to `10.20.20.200`
* **Primary DNS**: `10.20.20.10` (Windows DC01)
* **Secondary DNS**: `10.20.20.1` (pfSense Resolver fallback)
* **Domain Name**: `corp.local`

### 4. Security Operations Subnet (`em4` / SECURITY)
* **Status**: Enabled
* **Subnet**: `10.30.30.0/24`
* **Subnet Mask**: `255.255.255.0`
* **Available Range**: `10.30.30.100` to `10.30.30.200`
* **Offered DNS**: `10.30.30.1`

### 5. Malware Sandbox Subnet (`em5` / MALWARE)
* **Status**: Enabled
* **Subnet**: `10.40.40.0/24`
* **Subnet Mask**: `255.255.255.0`
* **Available Range**: `10.40.40.100` to `10.40.40.200`
* **Offered DNS**: `10.40.40.1` (Resolves sinkhole queries)

---

## Static DHCP Mapping Table

| Hostname | MAC Address | IP Address | Subnet | Description |
| :--- | :--- | :--- | :--- | :--- |
| `admin-kali` | `08:00:27:11:22:33` | `10.0.0.10` | Management | Admin Workstation |
| `dc01` | `08:00:27:AA:BB:CC` | `10.20.20.10` | AD | Active Directory DC01 |
| `wazuh-siem` | `08:00:27:44:55:66` | `10.30.30.10` | Security | SIEM / Wazuh Manager |
| `remnux` | `08:00:27:77:88:99` | `10.40.40.10` | Malware | REMnux Sandbox Workstation |
