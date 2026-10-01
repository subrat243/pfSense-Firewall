# Network Addressing & IP Allocation Plan

## Overview

This document outlines the IP addressing scheme, CIDR subnetting, static gateway assignments, DHCP allocation ranges, and broadcast domains for the pfSense enterprise lab environment.

---

## Master Subnet Table

| Network Name | Interface | Subnet (CIDR) | Network ID | Subnet Mask | Gateway IP (pfSense) | Usable IP Range | Broadcast IP | DHCP Pool Range |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **WAN** | `em0` | Dynamic / DHCP | Variable | Variable | Upstream NAT Router | Variable | Variable | Disabled (Upstream) |
| **Management** | `em1` | `10.0.0.0/24` | `10.0.0.0` | `255.255.255.0` | `10.0.0.1` | `10.0.0.2 - 10.0.0.254` | `10.0.0.255` | `10.0.0.100 - 10.0.0.200` |
| **Cyber Range**| `em2` | `10.10.10.0/24` | `10.10.10.0` | `255.255.255.0` | `10.10.10.1` | `10.10.10.2 - 10.10.10.254` | `10.10.10.255` | `10.10.10.100 - 10.10.10.200` |
| **Active Dir.** | `em3` | `10.20.20.0/24` | `10.20.20.0` | `255.255.255.0` | `10.20.20.1` | `10.20.20.2 - 10.20.20.254` | `10.20.20.255` | `10.20.20.100 - 10.20.20.200` |
| **Security** | `em4` | `10.30.30.0/24` | `10.30.30.0` | `255.255.255.0` | `10.30.30.1` | `10.30.30.2 - 10.30.30.254` | `10.30.30.255` | `10.30.30.100 - 10.30.30.200` |
| **Malware** | `em5` | `10.40.40.0/24` | `10.40.40.0` | `255.255.255.0` | `10.40.40.1` | `10.40.40.2 - 10.40.40.254` | `10.40.40.255` | `10.40.40.100 - 10.40.40.200` |
| **HOST_MGMT** | OPT5* | `192.168.56.0/24` | `192.168.56.0` | `255.255.255.0` | `192.168.56.2` | `192.168.56.1 - 192.168.56.254` | `192.168.56.255` | Static; DHCP disabled |
| **BLACKBOX** | OPT6* | `192.168.100.0/24` | `192.168.100.0` | `255.255.255.0` | `192.168.100.1` | `192.168.100.1 - 192.168.100.254` | `192.168.100.255` | Static; DHCP disabled |
| **WG_REMOTE** | WireGuard* | `10.50.50.0/24` | `10.50.50.0` | `255.255.255.0` | `10.50.50.1` | `10.50.50.1 - 10.50.50.254` | `10.50.50.255` | Static peer addresses |

\* OPT numbers and device names vary; verify by MAC address. HOST_MGMT, BLACKBOX, and WG_REMOTE are access networks, not additional lab segments. The Kali host uses `192.168.100.10/24` on `vboxnet1`; reserve `192.168.100.1` for pfSense.

---

## Detailed Network breakdown

### 1. Management Network (`10.0.0.0/24`)
* **Purpose**: Primary administration zone for hypervisor host, administration consoles, and pfSense management interfaces.
* **Gateway**: `10.0.0.1`
* **Static Host Allocations**:
  * `10.0.0.1`: pfSense WebGUI (`https://10.0.0.1:443`) & SSH (`port 22`)
  * `10.0.0.10`: Management Ubuntu VM
  * `10.0.0.50`: Out-of-band Hypervisor Management

The physical Kali host is not addressed in this subnet. Trusted access uses HOST_MGMT; black-box testing uses BLACKBOX.

### 2. Cyber Range Network (`10.10.10.0/24`)
* **Purpose**: Offense/Defense training, CTF boxes, vulnerable virtual machines (Metasploitable, VulnHub).
* **Gateway**: `10.10.10.1`
* **Static Host Allocations**:
  * `10.10.10.10`: Metasploitable 2
  * `10.10.10.20`: Metasploitable 3
  * `10.10.10.30` and above: Additional vulnerable targets
  * `10.10.10.50`: Optional SafeLine WAF

### 3. Active Directory Network (`10.20.20.0/24`)
* **Purpose**: Enterprise Windows Domain environment including Domain Controllers, Certificate Authorities, and Windows clients.
* **Gateway**: `10.20.20.1`
* **Static Host Allocations**:
  * `10.20.20.10`: Primary Domain Controller (DC01 - `lab.local`)
  * `10.20.20.11`: Secondary Domain Controller / PKI CA (DC02)
  * `10.20.20.50`: Windows 11 Enterprise Client (WKSTN-01)

### 4. Security Operations Network (`10.30.30.0/24`)
* **Purpose**: Defensive monitoring infrastructure (SIEM, log collectors, intrusion detection).
* **Gateway**: `10.30.30.1`
* **Static Host Allocations**:
  * `10.30.30.10`: Wazuh Indexer & Manager
  * `10.30.30.20`: Elastic Stack / Syslog Server
  * `10.30.30.30`: Suricata NIDS Probe / Zeek Network Monitor

### 5. Malware Sandbox Network (`10.40.40.0/24`)
* **Purpose**: Detonation and dynamic behavior analysis of untrusted binaries.
* **Gateway**: `10.40.40.1`
* **Static Host Allocations**:
  * `10.40.40.10`: FLARE-VM / REMnux Analysis Workstation
  * `10.40.40.20`: Cuckoo / CAPEv2 Sandbox Node
* **Routing Policy**: NO cross-subnet routing permitted. DNS requests conditionally intercepted or sinkholed by Unbound DNS.

Do not provide malware hosts with public DNS or WAN access. Prefer static addressing; if DHCP is required, point DNS only to an isolated INetSim/FakeNet-NG service on the same segment.

---

## DNS Server Allocation Strategy

* **Default Resolver**: pfSense Unbound is available to permitted lab segments; firewall and DHCP policy must restrict access by segment.
* **AD Domain Forwarder**: AD clients query DC01 (`10.20.20.10`) directly for `lab.local`; configure Unbound domain overrides only when other permitted segments require AD name resolution.
* **Malware DNS**: Use only a local fake-internet resolver inside `10.40.40.0/24`; do not forward malware DNS to public resolvers.

<!-- minimal update -->
