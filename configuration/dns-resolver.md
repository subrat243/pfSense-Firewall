# Unbound DNS Resolver & Domain Override Configuration

## Overview

pfSense uses **Unbound DNS Resolver** for approved lab DNS clients, custom host overrides, and optional Active Directory domain forwarding. DNS listener scope must respect segment isolation; MALWARE must never use pfSense for recursive public DNS.

---

## Core Settings

| Option | Recommended Value | Description |
| :--- | :--- | :--- |
| **Enable DNS Resolver** | `Checked` | Activates Unbound service |
| **Listen Interfaces** | Explicitly selected permitted interfaces; exclude MALWARE | Avoids providing a DNS path from the isolated malware network |
| **Outgoing Interfaces** | `WAN` | Performs root recursive lookup out WAN interface |
| **DNSSEC** | `Enabled` | Validates DNS response signatures |
| **DNS Query Forwarding** | `Disabled` (Recursive mode) | Direct root server recursive resolution |
| **DHCP Registration** | `Checked` | Automatically registers static DHCP hostnames in DNS |

---

## Active Directory Domain Overrides

To integrate internal Windows Active Directory domain name resolution without modifying root DNS forwarders:

| Domain | IP Address / Target | Description |
| :--- | :--- | :--- |
| `lab.local` | `10.20.20.10` | Forward `lab.local` queries to Windows DC01 when clients outside AD need domain resolution |
| `20.20.10.in-addr.arpa` | `10.20.20.10` | Reverse DNS lookup for Active Directory subnet |

---

## Host Overrides Table

| Host | Domain | IP Address | Description |
| :--- | :--- | :--- | :--- |
| `pfsense` | `lab.local` | `10.0.0.1` | pfSense Firewall WebGUI |
| `siem` | `lab.local` | `10.30.30.10` | Wazuh SIEM Dashboard |
| `wazuh` | `lab.local` | `10.30.30.10` | Wazuh Manager Alias |
| `dc01` | `lab.local` | `10.20.20.10` | Primary Domain Controller |

---

## Malware Network DNS

Do not offer Unbound to the Malware segment: recursive queries handled by pfSense could leave through the firewall even when the malware VM itself has no WAN route. Configure malware guests with static DNS pointing to an INetSim/FakeNet-NG service on `10.40.40.0/24`. Keep that fake resolver local to the segment and confirm pfSense has no Malware-to-WAN pass rule.

<!-- minimal update -->
