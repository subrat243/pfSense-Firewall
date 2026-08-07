# Stateful Firewall Rules & Security Policy Matrix

## Overview

pfSense processes firewall rules **top-to-bottom, first-match-wins**. Rules are stateful; once outbound traffic is allowed, return traffic is automatically permitted by the state table.

---

## Global Firewall Principles & Strategy

1. **Default Deny All**: Inbound traffic on WAN and all inter-subnet communications are blocked by default unless explicitly allowed.
2. **Management Isolation**: Only hosts in `Admin_Hosts` (`10.0.0.10`) can reach pfSense WebGUI and SSH ports (`Management_Ports`).
3. **Malware Sandbox Isolation**: Malware subnet (`10.40.40.0/24`) is strictly blocked from reaching any internal network (`RFC1918_Networks`).
4. **Active Directory Rule Scoping**: Domain clients reach AD DCs (`Domain_Controllers`) on specified `ActiveDirectory_Ports`.
5. **SIEM Telemetry**: Internal subnets forward syslog/telemetry to `SIEM_Collectors` on port `514`/`1514`.

---

## Detailed Interface Rule Matrices

### 1. Management Interface Rules (`em1` / LAN)

| Rule # | Action | Proto | Source | Port | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | Pass | TCP | `Admin_Hosts` | * | `LAN Address` | `Management_Ports` | Allow Admin Workstations to access pfSense WebGUI & SSH |
| **2** | Pass | UDP/TCP| `Management net` | * | `LAN Address` | `53` (DNS) | Allow Management DNS queries |
| **3** | Pass | IPv4 * | `Management net` | * | ! `RFC1918_Networks` | * | Allow Management subnet outbound Internet access |
| **4** | Pass | IPv4 * | `Management net` | * | `Internal_Lab_Subnets` | * | Allow Management full admin access to all internal subnets |
| **5** | Block | IPv4 * | * | * | * | * | Default Deny Catch-all |

---

### 2. Cyber Range Interface Rules (`em2` / CYBER)

| Rule # | Action | Proto | Source | Port | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | Pass | UDP/TCP| `CYBER net` | * | `CYBER Address` | `53` (DNS) | Allow DNS requests to pfSense Unbound |
| **2** | Pass | IPv4 * | `CYBER net` | * | `SIEM_Collectors` | `SIEM_Ingest_Ports` | Send security logs to Wazuh / SIEM |
| **3** | Pass | IPv4 * | `CYBER net` | * | `AD net` | `ActiveDirectory_Ports` | Allow attack/audit traffic to AD targets |
| **4** | Block | IPv4 * | `CYBER net` | * | `Management net` | * | Block Cyber Range from reaching Management network |
| **5** | Pass | IPv4 * | `CYBER net` | * | ! `RFC1918_Networks` | * | Allow Outbound Internet access for software updates |

---

### 3. Active Directory Interface Rules (`em3` / AD)

| Rule # | Action | Proto | Source | Port | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | Pass | UDP/TCP| `AD net` | * | `AD Address` | `53` (DNS) | Allow DNS to local resolver |
| **2** | Pass | IPv4 * | `AD net` | * | `SIEM_Collectors` | `SIEM_Ingest_Ports` | Forward Active Directory audit logs to SIEM |
| **3** | Block | IPv4 * | `AD net` | * | `Management net` | * | Block AD from accessing Management network |
| **4** | Pass | IPv4 * | `AD net` | * | ! `RFC1918_Networks` | * | Allow AD DCs and clients outbound Internet for WSUS/NTP |

---

### 4. Security Operations Rules (`em4` / SECURITY)

| Rule # | Action | Proto | Source | Port | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | Pass | UDP/TCP| `SECURITY net` | * | `SECURITY Address`| `53` (DNS) | Allow DNS |
| **2** | Pass | IPv4 * | `SECURITY net` | * | `Internal_Lab_Subnets` | * | Allow SIEM scanners to probe internal hosts |
| **3** | Pass | IPv4 * | `SECURITY net` | * | ! `RFC1918_Networks` | * | Outbound Internet access for threat intelligence feeds |

---

### 5. Malware Sandbox Rules (`em5` / MALWARE)

| Rule # | Action | Proto | Source | Port | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | Pass | UDP/TCP| `MALWARE net` | * | `MALWARE Address` | `53` (DNS) | Allow DNS requests (Intercepted/Sinkholed) |
| **2** | **Block**| IPv4 * | `MALWARE net` | * | `RFC1918_Networks` | * | **CRITICAL: Block all inter-VLAN access to internal networks** |
| **3** | **Block**| IPv4 * | `MALWARE net` | * | `WAN Address` | * | Block direct access to host WAN |
| **4** | Pass | IPv4 * | `MALWARE net` | * | ! `RFC1918_Networks` | * | (Optional) Controlled Inet detonation via INetSim / Tor |

<!-- minimal update -->
