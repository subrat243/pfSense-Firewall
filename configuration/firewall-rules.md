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

| Order | Action | Proto | Source | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass | TCP | `AD net` | `SIEM_Collectors` | `1514`, `1515`, `5044` | Allow only configured Windows log forwarding |
| 2 | Block | IPv4 * | `AD net` | `CYBER_NET` | * | AD must not reach the attack range unprompted |
| 3 | Block | IPv4 * | `AD net` | `MALWARE_NET` | * | Prevent access to malware analysis |
| 4 | Pass (optional) | IPv4 * | Approved AD hosts | WAN / non-RFC1918 | Required update ports | Enable only for controlled patching |

AD clients should use the domain controller (`10.20.20.10`) for DNS; that same-subnet traffic does not traverse pfSense. Avoid a broad AD-to-Internet allow rule.

---

### 4. Security Operations Rules (`em4` / SECURITY)

| Order | Action | Proto | Source | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass | IPv4 * | Approved SIEM hosts | Required monitored hosts | Required service ports | Optional active polling; scope by source and destination |
| 2 | Pass (optional) | TCP/UDP | SIEM hosts | WAN / non-RFC1918 | Required update/feed ports | Enable only when needed |

Passive Suricata/Zeek collection does not require a routed pass rule from each source segment. Configure VirtualBox promiscuous mode or a supported traffic-mirroring design separately; do not use a broad Security-to-all rule as a substitute.

---

### 5. Malware Sandbox Rules (`em5` / MALWARE)

| Order | Action | Proto | Source | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass (optional) | UDP/TCP | `MALWARE net` | Local fake-DNS host only | `53` | Use only with INetSim/FakeNet-NG in the malware segment |
| 2 | Block | IPv4 * | `MALWARE net` | `MGMT_NET`, `CYBER_NET`, `AD_NET`, `SECURITY_NET`, `10.50.50.0/24` | * | Explicitly deny every protected routed network |
| 3 | Block | IPv4 * | `MALWARE net` | WAN | * | **Critical: no Internet egress** |

Do not add an allow-to-non-RFC1918 rule, public DNS exception, NAT rule, or second malware VM NIC attached to NAT/bridged networking. The implicit deny blocks anything else. Keep samples offline from the host and transfer artifacts only using controlled read-only media or a quarantined workflow.

<!-- minimal update -->
