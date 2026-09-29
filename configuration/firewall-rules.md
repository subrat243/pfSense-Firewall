# Stateful Firewall Rules & Security Policy Matrix

## Overview

pfSense processes firewall rules **top-to-bottom, first-match-wins**. Rules are stateful; once outbound traffic is allowed, return traffic is automatically permitted by the state table.

---

## Global Firewall Principles & Strategy

1. **Default Deny**: pfSense has an implicit deny at the bottom of each interface ruleset. Add only the pass rules each segment needs.
2. **Ingress Evaluation**: Rules are evaluated on the interface where a connection enters pfSense. A Cyber-to-AD policy belongs on CYBER, not AD.
3. **Management**: MGMT is trusted for lab administration. HOST_MGMT is a separate, source-restricted path from physical Kali; do not put the host on a lab internal network.
4. **Malware Containment**: MALWARE has no WAN or cross-segment pass rule. Explicit blocks document this critical boundary; keep them above any permitted local telemetry exception.
5. **SIEM Telemetry**: Permit only the required source-to-SIEM-host ports, above any broader block. Confirm exact protocols and ports for the selected collector.

---

## Detailed Interface Rule Matrices

### 1. Management Interface Rules (`em1` / MGMT)

| Rule # | Action | Proto | Source | Port | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | Pass | IPv4 * | `MGMT net` | * | `Internal_Lab_Subnets` | * | Trusted management VM can administer lab segments |
| **2** | Pass | TCP | `Admin_Hosts` | * | `MGMT Address` | `Management_Ports` | Allow approved administrators to reach pfSense WebGUI/SSH |
| **3** | Pass | UDP/TCP | `MGMT net` | * | `MGMT Address` | `53` (DNS) | Allow management DNS queries |

Avoid a broad `MGMT net -> any` pass rule if the intent is to protect the firewall itself; the implicit deny handles anything not explicitly allowed.

### 2. Cyber Range Interface Rules (`em2` / CYBER)

| Order | Action | Proto | Source | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass (optional) | IPv4 * | `CYBER net` | WAN / non-RFC1918 | Required update ports | Enable only during patching or when required |
| 2 | Pass | UDP | `CYBER net` | `SIEM_Collectors` | `514` | Syslog, if configured |
| 3 | Pass | TCP | `CYBER net` | `SIEM_Collectors` | `1514`, `1515`, `5044` | Wazuh agent / Beats, only deployed ports |
| 4 | Pass (disabled by default) | IPv4 * | `CYBER net` | `AD_NET` | Required AD ports | Temporary pivot exercise only |
| 5 | Block | IPv4 * | `CYBER net` | `MGMT_NET` | * | Protect the management plane |
| 6 | Block | IPv4 * | `CYBER net` | `MALWARE_NET` | * | Prevent access to malware analysis |
| 7 | Block | IPv4 * | `CYBER net` | `SECURITY_NET` | * | Block everything except prior SIEM telemetry allows |

Keep the SIEM allows above the Security block and scope destination to the actual collector address. Do not add a broad Cyber-to-AD or Cyber-to-WAN rule permanently.

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
