# Firewall Aliases Reference Guide

## Overview

pfSense **Aliases** group IP addresses, subnets, ports, or hostnames into reusable names. Changing an alias updates every rule that uses it. Aliases are referenced throughout the [firewall rule matrix](firewall-rules.md), so create them **before** writing any rules.

## Related Documentation

- [Repository overview](../README.md)
- [Firewall rule matrix](firewall-rules.md)
- [NAT & port forwarding](nat.md)
- [DNS resolver configuration](dns-resolver.md)
- [IP allocation plan](../architecture/ip-plan.md)

---

## Creating Aliases in the WebGUI

1. Go to **Firewall → Aliases**.
2. Open the tab for the type: **IP** (hosts and networks) or **Ports**.
3. Click **Add**, then enter the name, description, type and contents.
4. Click **Save**. Repeat for every alias, then click **Apply Changes** once at the end.

Alias names may contain only letters, numbers and underscores, and must not start with a number.

---

## Defined Aliases

### 1. Subnet Aliases (Type: Network)

One alias per lab segment, plus the two access paths.

| Alias | Contents | Description |
| :--- | :--- | :--- |
| `MGMT_NET` | `10.0.0.0/24` | Admin workstations and pfSense WebGUI |
| `CYBER_NET` | `10.10.10.0/24` | Cyber Range / DMZ: CTF targets and pentest VMs |
| `AD_NET` | `10.20.20.0/24` | Active Directory: DCs and Windows members |
| `SECURITY_NET` | `10.30.30.0/24` | Security Operations: SIEM, Wazuh, Suricata |
| `MALWARE_NET` | `10.40.40.0/24` | Isolated malware analysis sandbox |
| `HOST_MGMT_NET` | `192.168.56.0/24` | Trusted physical Kali administration link |
| `WG_REMOTE_NET` | `10.50.50.0/24` | Remote WireGuard peers |

### 2. Grouped Network Aliases (Type: Network)

| Alias | Contents | Description |
| :--- | :--- | :--- |
| `Internal_Lab_Subnets` | `10.0.0.0/24`, `10.10.10.0/24`, `10.20.20.0/24`, `10.30.30.0/24`, `10.40.40.0/24` | The five segmented lab subnets. Excludes HOST_MGMT and WireGuard. |
| `RFC1918_Networks` | `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` | All private IPv4 space. Used as `! RFC1918_Networks` to mean "the Internet". |

### 3. Host Aliases (Type: Host)

| Alias | Contents | Description |
| :--- | :--- | :--- |
| `Admin_Hosts` | `10.0.0.10`, `10.0.0.15` | Workstations allowed to reach the pfSense WebGUI and SSH |
| `SIEM_Collectors` | `10.30.30.10`, `10.30.30.20` | Wazuh and log management servers |
| `Domain_Controllers` | `10.20.20.10`, `10.20.20.11` | Windows Active Directory domain controllers |
| `SIEM_Poll_Targets` | *Specific hosts only* | Hosts the SIEM actively polls. Never use a whole subnet; keep `MALWARE_NET` hosts out unless needed. |

### 4. Port Aliases (Type: Port)

| Alias | Contents | Description |
| :--- | :--- | :--- |
| `Management_Ports` | `22` (SSH), `443` (HTTPS) | pfSense administration |
| `Web_Ports` | `80` (HTTP), `443` (HTTPS) | Updates and threat-intel feeds |
| `SIEM_Agent_Ports` | `1514` (Wazuh agent), `1515` (Wazuh enrollment), `5044` (Beats) | TCP log and telemetry ingestion |
| `ActiveDirectory_Ports` | `53`, `88`, `135`, `139`, `445`, `389`, `636`, `3268`, `3269` | DNS, Kerberos, RPC, SMB, LDAP/LDAPS, Global Catalog |

Syslog (`514/UDP`) is entered directly in the rule rather than in an alias, because `SIEM_Agent_Ports` is TCP-only. Do not expose Elasticsearch directly through any alias.

---

## Alias Usage Map

| Alias | Used in |
| :--- | :--- |
| `MGMT_NET` | MGMT, CYBER, SECURITY blocks and passes |
| `CYBER_NET`, `AD_NET`, `SECURITY_NET`, `MALWARE_NET` | Source or destination of each segment's rules |
| `HOST_MGMT_NET` | MGMT rule 4 and MALWARE rule 3 (keeps Kali link one-way) |
| `WG_REMOTE_NET` | MALWARE rule 3 |
| `Internal_Lab_Subnets` | MGMT rule 5 and MALWARE rule 3 |
| `RFC1918_Networks` | Update rules on MGMT, CYBER, AD, SECURITY |
| `Admin_Hosts` | MGMT rule 1 |
| `SIEM_Collectors` | CYBER rules 2-3, AD rule 1 |
| `Domain_Controllers` | CYBER rule 5, AD rule 5 |
| `SIEM_Poll_Targets` | SECURITY rule 2 |
| `Management_Ports` | MGMT rule 1 |
| `Web_Ports` | Update rules on MGMT, CYBER, AD, SECURITY |
| `SIEM_Agent_Ports` | CYBER rule 3, AD rule 1 |
| `ActiveDirectory_Ports` | CYBER rule 5 (pivot drill) |

> **Tip:** `MALWARE_NET` in a rule is much clearer than `10.40.40.0/24`, and a subnet change then needs editing in one place only.

> **Warning:** Check that a subnet alias still matches the IP plan before relying on it in a block rule. A wrong alias in a block rule fails silently.
