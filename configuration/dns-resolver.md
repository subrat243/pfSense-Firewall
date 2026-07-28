# Unbound DNS Resolver & Domain Override Configuration

## Overview

pfSense uses **Unbound DNS Resolver** for full recursive resolution with DNSSEC validation, custom host overrides, domain overrides for Active Directory integration, and DNS sinkholing for threat defense.

---

## Core Settings

| Option | Recommended Value | Description |
| :--- | :--- | :--- |
| **Enable DNS Resolver** | `Checked` | Activates Unbound service |
| **Listen Interfaces** | `All` (or Mgmt, Cyber, AD, Sec, Malware) | Responds to DNS queries on all subnets |
| **Outgoing Interfaces** | `WAN` | Performs root recursive lookup out WAN interface |
| **DNSSEC** | `Enabled` | Validates DNS response signatures |
| **DNS Query Forwarding** | `Disabled` (Recursive mode) | Direct root server recursive resolution |
| **DHCP Registration** | `Checked` | Automatically registers static DHCP hostnames in DNS |

---

## Active Directory Domain Overrides

To integrate internal Windows Active Directory domain name resolution without modifying root DNS forwarders:

| Domain | IP Address / Target | Description |
| :--- | :--- | :--- |
| `corp.local` | `10.20.20.10` | Forward all `.corp.local` DNS queries to Windows DC01 |
| `20.20.10.in-addr.arpa` | `10.20.20.10` | Reverse DNS lookup for Active Directory subnet |

---

## Host Overrides Table

| Host | Domain | IP Address | Description |
| :--- | :--- | :--- | :--- |
| `pfsense` | `lab.local` | `10.0.0.1` | pfSense Firewall WebGUI |
| `siem` | `lab.local` | `10.30.30.10` | Wazuh SIEM Dashboard |
| `wazuh` | `lab.local` | `10.30.30.10` | Wazuh Manager Alias |
| `dc01` | `corp.local` | `10.20.20.10` | Primary Domain Controller |

---

## Malware Network DNS Sinkholing

For the Malware Sandbox network (`10.40.40.0/24`), custom Unbound options can sinkhole known malicious C2 domains to local loopback `127.0.0.1` or INetSim fake services:

```text
server:
  local-zone: "malicious-c2-domain.com" redirect
  local-data: "malicious-c2-domain.com A 127.0.0.1"
```
