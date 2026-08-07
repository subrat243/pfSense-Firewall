# Enterprise Firewall & Network Segmentation with pfSense

## Lab Architecture

![pfSense Lab Architecture](architecture/topology.png)

---

## Overview

This project documents the design, deployment, configuration, and validation of an **Enterprise-grade Virtual Firewall and Network Segmentation Infrastructure** powered by **pfSense Community Edition**.

Built as the secure core of a cybersecurity home lab environment, this virtual firewall acts as the gateway between the external Internet and five isolated internal network segments (Management, Cyber Range, Active Directory, Security Infrastructure, and Malware Analysis Lab).

---

## Technical Specifications & Architecture

| Parameter | Specification / Allocation |
| :--- | :--- |
| **Firewall Engine** | pfSense CE 2.7.x (FreeBSD 14.0-RELEASE base) |
| **Virtual Machine Specifications** | 2 vCPU, 1024 MB RAM, 20 GB VDI Storage |
| **Hypervisor** | Oracle VM VirtualBox |
| **Total Interfaces** | 6 (1 WAN NAT + 5 Segmented Internal Networks) |
| **Core Services** | Unbound DNS Resolver, DHCP Server, Outbound NAT, Stateful Packet Inspection |

---

## Network Segmentation Summary

| Interface Name | Logical Network Name | Subnet Range | Gateway IP | Description & Access Policy |
| :--- | :--- | :--- | :--- | :--- |
| `em0` | **WAN** | DHCP (NAT) | Variable | External Internet Access |
| `em1` | **Management (Mgmt)** | `10.0.0.0/24` | `10.0.0.1` | Admin workstations, pfSense WebGUI/SSH, full outbound access |
| `em2` | **Cyber Range (Cyber)** | `10.10.10.0/24` | `10.10.10.1` | CTF targets, attack platforms, penetration testing VMs |
| `em3` | **Active Directory (AD)** | `10.20.20.0/24` | `10.20.20.1` | Domain Controllers, enterprise Windows member servers |
| `em4` | **Security (Security)** | `10.30.30.0/24` | `10.30.30.1` | Security monitoring (Wazuh, SIEM, Suricata, syslog server) |
| `em5` | **Malware (Malware)** | `10.40.40.0/24` | `10.40.40.1` | Isolated malware analysis sandbox; zero cross-VLAN access |

---

## Repository Structure

```text
.
├── README.md                           # Main Project Documentation & Architecture Overview
├── architecture/
│   ├── network-diagram.drawio          # Draw.io editable network topology source diagram
│   ├── topology.png                    # Rendered visual topology network diagram
│   ├── topology.svg                    # Vector graphic network topology diagram
│   ├── ip-plan.md                      # Detailed IP allocation, VLAN, and subnetting plan
│   └── design-rationale.md             # Detailed networking design decisions & isolation rationale
├── installation/
│   ├── virtualbox.md                   # VirtualBox VM creation step-by-step guide
│   ├── pfsense-install.md              # pfSense ISO installation walkthrough
│   ├── interface-assignment.md         # NIC mapping (em0-em5) to networks
│   └── dhcp.md                         # DHCP scope configuration per interface
├── configuration/
│   ├── firewall-rules.md               # Complete firewall rules matrix & policy logic
│   ├── dns-resolver.md                 # Unbound DNS, domain overrides, & hardening
│   ├── nat.md                          # Outbound NAT rules & port forwarding setup
│   └── aliases.md                      # Firewall aliases definition and usage
├── screenshots/                        # Screenshots of WebGUI configuration states
├── validation/
│   ├── connectivity.md                 # Inter-VLAN routing and ping matrix validation
│   └── troubleshooting.md              # Common setup issues and diagnostic solutions
└── backup/
    └── config.xml                      # Production-ready exported pfSense configuration
```

---

## Structured Documentation & Learning Roadmap

Follow this step-by-step reading and implementation guide to build a deep theoretical understanding and successfully deploy the lab environment.

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        STRUCTURED LEARNING PATH                        │
└────────────────────────────────────────────────────────────────────────┘
  1. UNDERSTAND ──> 2. PROVISION ──> 3. INSTALL ──> 4. CONFIGURE ──> 5. VERIFY
```

---

### Phase 1: Conceptual Understanding & Architecture (The "WHY")

*Before configuring any virtual machines, read these documents to understand the architectural design decisions.*

1. **[Design & Architectural Rationale](architecture/design-rationale.md)**
   * **Purpose**: Learn *why* pfSense acts as central gateway, *why* 6 NICs simulate enterprise hardware, *why* VirtualBox `intnet-*` isolates host Kali from lab networks, and *why* a dedicated Ubuntu Management VM is used.
2. **Network Topology Diagrams ([PNG](architecture/topology.png) | [Draw.io](architecture/network-diagram.drawio))**
   * **Purpose**: Visualize physical interface mappings (`em0`–`em5`), logical security zones, and inter-subnet routing paths.
3. **[Master IP Allocation & Subnet Plan](architecture/ip-plan.md)**
   * **Purpose**: Master the CIDR IP schemes (`10.0.0.0/24`, `10.10.10.0/24`, etc.), gateway addresses, static reservations, DHCP lease ranges, and Unbound DNS domain overrides.

---

### Phase 2: Hypervisor Provisioning & Base OS Setup (The "BUILD")

*Follow these guides sequentially to build the hypervisor virtual machines.*

1. **[VirtualBox Hardware Provisioning Guide](installation/virtualbox.md)** *(or run [`installation/setup-vbox-vm.sh`](installation/setup-vbox-vm.sh))*
   * **Purpose**: Allocate 2 vCPUs, 1024 MB RAM, 20 GB VDI disk, and attach 6 Network Adapters (NAT WAN + 5 Internal Networks).
2. **[pfSense OS Installation Guide](installation/pfsense-install.md)**
   * **Purpose**: Boot pfSense ISO, format disk partitions, install FreeBSD base, and complete initial system reboot.
3. **[Console Interface Assignment Guide](installation/interface-assignment.md)**
   * **Purpose**: Assign `em0` to WAN, `em1` to LAN, `em2`–`em5` to OPT1–OPT4, and configure initial LAN IP address (`192.168.1.1` / `10.0.0.1`).
4. **Ubuntu Management VM Deployment** *(Refer to [Design Rationale](architecture/design-rationale.md#5-dedicated-management-workstation-rationale-why-ubuntu))*
   * **Purpose**: Create Ubuntu VM on `intnet-mgmt`, obtain DHCP lease from pfSense, and launch WebGUI at `https://192.168.1.1` (or `https://10.0.0.1`).

---

### Phase 2.5: Post-Wizard Initial Configuration Protocol (The "CONFIGURE")

> **Do not start installing VMs yet.** Complete these 6 steps to configure pfSense properly before any lab VMs are deployed.

1. **[Step 1 — Rename Interfaces](installation/interface-assignment.md#step-1--rename-interfaces)** *(in Interface Assignment Guide)*
   * **Purpose**: Rename `LAN` → `MGMT`, `OPT1` → `CYBER`, `OPT2` → `AD`, `OPT3` → `SECURITY`, `OPT4` → `MALWARE` so firewall rules are human-readable.
2. **[Step 2 — Configure Each Interface IP](installation/interface-assignment.md#step-2--configure-each-interface-ip--gateway)** *(in Interface Assignment Guide)*
   * **Purpose**: Assign static gateway IPs (`10.x.x.1/24`) per interface. Each IP becomes the default gateway and DNS server for that subnet.
3. **[Step 3 — Enable DHCP Across All Subnets](installation/dhcp.md#step-3--enable-dhcp-server-across-all-subnets-post-wizard)** *(in DHCP Configuration Guide)*
   * **Purpose**: Configure `.100`–`.200` pools on every interface so VMs automatically receive an IP, gateway, and DNS on boot.
4. **[Step 4 — Verify Internet Egress](installation/pfsense-install.md#step-4--verify-internet-egress-post-wizard)** *(in Installation Guide)*
   * **Purpose**: Use **Diagnostics → Ping** to ping `1.1.1.1` (NAT check) and `google.com` (DNS check) before deploying any VMs.
5. **[Step 5 — Create Core Network Aliases](configuration/aliases.md#step-5--create-network-subnet-aliases-post-wizard)** *(in Aliases Guide)*
   * **Purpose**: Create `MGMT_NET`, `CYBER_NET`, `AD_NET`, `SECURITY_NET`, `MALWARE_NET` aliases used by all downstream firewall rules.
6. **[Step 6 — Take Baseline VirtualBox Snapshot](installation/pfsense-install.md#step-6--take-a-baseline-virtualbox-snapshot-post-wizard)** *(in Installation Guide)*
   * **Purpose**: Snapshot the fully configured pfSense VM as `01 - Fresh pfSense` for instant rollback if anything breaks later.

---

### Phase 3: WebGUI Services & Policy Enforcement (The "ENFORCE")

*Perform these configurations via the pfSense WebGUI from inside the Ubuntu Management VM.*

1. **[DHCP Server Configuration](installation/dhcp.md)**
   * **Purpose**: Enable and define DHCP pools (`.100`–`.200`) across Management, Cyber Range, AD, Security, and Malware interfaces.
2. **[Firewall Rule Matrix & Policies](configuration/firewall-rules.md)** & **[Aliases](configuration/aliases.md)**
   * **Purpose**: Implement stateful default-deny rules, management access policies, inter-VLAN restrictions, and malware containment.
3. **[Outbound NAT & Port Forwarding](configuration/nat.md)**
    * **Purpose**: Set up Hybrid/Manual Outbound NAT rules for external internet access from authorized internal subnets.
4. **[Unbound DNS Resolver & Hardening](configuration/dns-resolver.md)**
    * **Purpose**: Configure pfSense Unbound DNS resolver with Active Directory domain overrides (`.corp.local`).

---

### Phase 4: Validation, Verification & Diagnostics (The "VERIFY")

*Validate that all firewall policies work as designed and resolve any issues.*

 1. **[Inter-VLAN Connectivity & Validation Matrix](validation/connectivity.md)**
    * **Purpose**: Execute cross-subnet ping tests, Nmap scans, and WebGUI access checks to confirm rule enforcement.
 2. **[Troubleshooting & Diagnostics Guide](validation/troubleshooting.md)**
    * **Purpose**: Diagnostic workflows for common errors (DHCP lease failures, WebGUI lockout, DNS loops, VirtualBox adapter mismatches).

---

## License & Attribution

This configuration is designed for enterprise lab simulation and cybersecurity training. Distributed under the MIT License.

<!-- minimal update -->
