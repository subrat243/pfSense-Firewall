# Architectural & Networking Design Rationale

## Executive Overview

This document explains the technical rationale and architectural decisions behind the **pfSense Enterprise Lab & Cyber Range**. It details **why** specific networking paradigms, interfaces, isolation mechanisms, and management workflows were selected.

---

## 1. Core Firewall Architecture (Why pfSense?)

In this virtual lab, **pfSense Community Edition** acts as the central router, security gateway, and policy enforcement point for all traffic.

```text
                                 Internet
                                     │
                             VirtualBox NAT
                                     │
                             pfSense Firewall
                             ┌─────────────┐
                             │             │
                             │     WAN     │
                             │     LAN     │
                             │    OPT1     │
                             │    OPT2     │
                             │    OPT3     │
                             │    OPT4     │
                             └─────────────┘
```

### Key Gateway Responsibilities:
* **Stateful Packet Inspection (SPI)**: Enforces default-deny inter-VLAN firewall rules.
* **Routing & NAT**: Manages Outbound Network Address Translation for Internet access.
* **Core Network Services**: Provides Unbound DNS resolution, domain overrides, and DHCP scopes for each subnet.
* **Network Segmentation**: Acts as the single point of control separating trusted management, training zones, enterprise infrastructure, and malicious sandboxes.

---

## 2. Multi-Interface Physical Emulation

VirtualBox presents eight network adapters to pfSense: one WAN, five isolated lab networks, and two host-only access paths. WireGuard is a software interface and does not consume a VirtualBox adapter.

| pfSense Interface | System Device | Mapped Network Segment | VirtualBox Attachment Mode |
| :--- | :--- | :--- | :--- |
| **WAN** | `em0` | Internet Gateway | VirtualBox NAT |
| **LAN** | `em1` | Management (`intnet-mgmt`) | Internal Network |
| **OPT1** | `em2` | Cyber Range (`intnet-cyber`) | Internal Network |
| **OPT2** | `em3` | Active Directory (`intnet-ad`) | Internal Network |
| **OPT3** | `em4` | Security Operations (`intnet-sec`) | Internal Network |
| **OPT4** | `em5` | Malware Sandbox (`intnet-malware`)| Internal Network |
| **OPT5** | Verify by MAC | HOST_MGMT (`vboxnet0`) | Host-only Adapter |
| **OPT6** | Verify by MAC | BLACKBOX (`vboxnet1`) | Host-only Adapter |

The `emN` examples are not guaranteed. Compare each VirtualBox MAC address with pfSense **Interfaces → Assignments** before configuring it. See the [interface assignment guide](../installation/interface-assignment.md).

> [!NOTE]
> In an enterprise firewall (e.g., Netgate, Palo Alto, Fortinet), distinct physical Ethernet ports segregate physical switches into distinct security zones (DMZ, Employee LAN, Guest Wi-Fi, Server Farm). Here, VirtualBox Internal Networks simulate physical switches.

---

## 3. WAN vs. LAN Conceptual Model

### Wide Area Network (WAN)
* **Definition**: The untrusted external network (the Internet).
* **Implementation**: pfSense `em0` connects to VirtualBox **NAT**.
* **Traffic Flow**:
  ```text
  Lab VMs ──> pfSense WAN ──> VirtualBox NAT ──> Host Wi-Fi/NIC ──> Internet
  ```

### Local Area Network (LAN) / Management Enclave
* **Definition**: The highly trusted administration zone used exclusively for firewall management and out-of-band administration.
* **Default Addressing**: `192.168.1.1/24` (migrating to `10.0.0.1/24` for production lab structure).

---

## 4. VirtualBox Internal Network Isolation

### Host Access Uses Explicit Host-only Links
VirtualBox **Internal Networks** (`intnet-*`) create isolated virtual switches visible only to VMs attached to the matching name. The physical Kali host does not join any of the five lab segments directly. It reaches them through pfSense using separate access paths:

```text
                         Virtual Switch (intnet-mgmt)
                   ┌──────────────────────────────────────┐
                   │                                      │
              ┌────┴──────┐                          ┌────┴──────┐
              │  pfSense  │                          │ Ubuntu VM │
              └───────────┘                          └───────────┘
                    ▲                                      ▲
                    │                                      │
             Guest Interface                        Guest Interface
                                        
                        Host OS (Kali Linux)
                                 │
                     Host-only `vboxnet0`
                                 │
                         pfSense HOST_MGMT
```

* **HOST_MGMT** (`192.168.56.1` Kali, `192.168.56.2` pfSense) is the trusted administrative path; host routes pass through pfSense.
* **BLACKBOX** (`192.168.100.10` Kali, `192.168.100.1` pfSense) simulates an untrusted attacker and is restricted to CYBER. Disconnect HOST_MGMT and remove its trusted routes during this mode.
* **WireGuard** (`10.50.50.0/24`) supports remote administration with explicit destination/port rules. Never expose the pfSense GUI, SSH, or SIEM directly to WAN.

---

## 5. Dedicated Management Workstation Rationale (Why Ubuntu?)

In an enterprise environment, firewall administrators do not browse the web, execute code, or run attack tools from the firewall appliance itself. Administration is performed via a dedicated **Privileged Access Workstation (PAW)**.

### Why use an Ubuntu Management VM instead of Host Kali?
1. **Role Separation**: Host Kali acts as the hypervisor host and primary attack platform. Placing Kali inside the management network would collapse the security boundary between attacker and administrator.
2. **Clean Management Hub**: The Ubuntu VM hosts administrative tools:
   * **pfSense WebGUI**: `https://10.0.0.1` (or `192.168.1.1`)
   * **Wazuh / SIEM Dashboard**: `https://10.30.30.10`
   * **Active Directory Admin Consoles**: Remote Server Administration Tools (RSAT) / SSH / RDP
3. **Firewall Core Philosophy**: A firewall's sole function is **packet processing**. Offloading interactive tasks to a dedicated workstation minimizes attack surface on the gateway.

---

## 6. Network Segmentation Rationale

### The Danger of Flat Networks
If all lab assets reside on a single subnet:
* Malware detonated in a test VM can directly scan and infect Active Directory Domain Controllers.
* Broadcast and ARP traffic flood all hosts.
* Stateful firewall policy enforcement is impossible between hosts on the same Layer 2 segment.

### The Segmented Solution
By enforcing strict subnets per zone, pfSense evaluates every inter-zone packet against explicit rules:

```text
Management (10.0.0.0/24) ──────> Trusted administrative access, explicitly scoped
Cyber Range (10.10.10.0/24) ───> Optional updates; scoped SIEM telemetry; no lateral access by default
Active Directory (10.20.20.0/24) ──> Scoped SIEM telemetry; no Cyber/Malware access
Security Operations (10.30.30.0/24) ─> SIEM; only required polling and updates
Malware Sandbox (10.40.40.0/24) ────> No WAN/cross-segment access; local fake DNS only
```

---

## Summary Checklist of Accomplished Setup

- [x] Provisioned pfSense virtual firewall with eight VirtualBox adapters (WAN, five lab segments, and two host-only access links).
- [x] Connected **WAN (`em0`)** to VirtualBox **NAT** for external internet routing.
- [x] Assigned **LAN (`em1`)** to isolated Internal Network `intnet-mgmt`.
- [x] Assigned **OPT1–OPT4 (`em2`–`em5`)** to dedicated Internal Networks (`intnet-cyber`, `intnet-ad`, `intnet-sec`, `intnet-malware`).
- [x] Provisioned Ubuntu Management Workstation on `intnet-mgmt` to perform initial WebGUI setup and subnet configuration.

<!-- minimal update -->
