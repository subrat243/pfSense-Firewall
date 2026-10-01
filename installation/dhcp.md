# Dynamic Host Configuration Protocol (DHCP) Scopes

## Overview

pfSense provides DHCP only on segments where dynamic addressing is appropriate. Keep static infrastructure addresses outside those pools and do not automatically enable DHCP on the isolated malware or host-only access networks.

---

## Global DHCP Settings

* **Lease Duration**: Default 7200 seconds (2 hours), Maximum 86400 seconds (24 hours).
* **DNS Servers Offered**: Gateway IP (`x.x.x.1`) pointing to pfSense Unbound DNS Resolver.
* **Domain Name**: `lab.local` where applicable. AD clients should use DC01 (`10.20.20.10`) as their DNS server.

---

## Step 3 — Enable DHCP Server Across All Subnets (Post-Wizard)

Enable DHCP only on the required internal interfaces via **Services** → **DHCP Server**. Select each interface tab and configure a pool; do not enable it indiscriminately on every interface.

> [!TIP]
> **Why enable DHCP before deploying VMs?**
> When you boot any new VM, it automatically receives an IP address, default gateway, and DNS resolver — all pre-configured. No manual network setup is needed on guest machines.

### WebGUI Configuration Steps

1. Navigate to **Services** → **DHCP Server**.
2. Select the interface tab (e.g. `MGMT`, `CYBER`, `AD`, `SECURITY`, `MALWARE`).
3. Check **Enable DHCP server on [interface] interface**.
4. Set the **Range** as shown in the table below.
5. Click **Save** on each tab.

### DHCP Scope Summary Table

| Interface | Subnet | DHCP Pool Start | DHCP Pool End | Offered DNS |
| :--- | :--- | :--- | :--- | :--- |
| **MGMT** | `10.0.0.0/24` | `10.0.0.100` | `10.0.0.200` | `10.0.0.1` |
| **CYBER** | `10.10.10.0/24` | `10.10.10.100` | `10.10.10.200` | `10.10.10.1` |
| **AD** | `10.20.20.0/24` | `10.20.20.100` | `10.20.20.200` | `10.20.20.10` (DC01) |
| **SECURITY** | `10.30.30.0/24` | `10.30.30.100` | `10.30.30.200` | `10.30.30.1` |
| **MALWARE** | `10.40.40.0/24` | Disabled | Disabled | Static only, or local fake-DNS service |

Do not run DHCP on HOST_MGMT or BLACKBOX; the Kali and pfSense addresses are static. Do not advertise a public resolver to malware guests. If malware DHCP is required for an isolated exercise, serve it from a local fake-internet VM on the malware segment and provide no route to WAN.

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
* **Domain Name**: `lab.local`

### 4. Security Operations Subnet (`em4` / SECURITY)
* **Status**: Enabled
* **Subnet**: `10.30.30.0/24`
* **Subnet Mask**: `255.255.255.0`
* **Available Range**: `10.30.30.100` to `10.30.30.200`
* **Offered DNS**: `10.30.30.1`

### 5. Malware Sandbox Subnet (`em5` / MALWARE)
* **Status**: Disabled by default
* **Subnet**: `10.40.40.0/24`
* **Subnet Mask**: `255.255.255.0`
* **Available Range**: None; use static addresses or a dedicated local service
* **Offered DNS**: None from pfSense; use an isolated local fake-DNS service when needed

---

## Static DHCP Mapping Table

| Hostname | MAC Address | IP Address | Subnet | Description |
| :--- | :--- | :--- | :--- | :--- |
| `management-ubuntu` | `08:00:27:11:22:33` | `10.0.0.10` | Management | Management workstation |
| `dc01` | `08:00:27:AA:BB:CC` | `10.20.20.10` | AD | Active Directory DC01 |
| `wazuh-siem` | `08:00:27:44:55:66` | `10.30.30.10` | Security | SIEM / Wazuh Manager |
| `remnux` | `08:00:27:77:88:99` | `10.40.40.10` | Malware | REMnux Sandbox Workstation |

<!-- minimal update -->
