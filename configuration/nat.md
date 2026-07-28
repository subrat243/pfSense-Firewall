# Network Address Translation (NAT) & Port Forwarding

## Overview

Network Address Translation (NAT) maps private RFC1918 subnets (`10.0.0.0/8`) to external public/WAN IP addresses. pfSense handles both **Outbound NAT** (masquerading internal hosts for Internet access) and **Port Forwarding (Inbound NAT)**.

---

## Outbound NAT Configuration

pfSense defaults to **Automatic Outbound NAT rule generation**. For granular control over segmented subnets, **Hybrid** or **Manual Outbound NAT** rule generation is configured.

### Outbound NAT Rules Matrix

| Interface | Source Subnet | Source Port | Destination | Dest Port | NAT Address | NAT Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **WAN** | `10.0.0.0/24` (Mgmt) | * | * | * | `WAN address` | * | Auto NAT for Management subnet |
| **WAN** | `10.10.10.0/24` (Cyber) | * | * | * | `WAN address` | * | Auto NAT for Cyber Range subnet |
| **WAN** | `10.20.20.0/24` (AD) | * | * | * | `WAN address` | * | Auto NAT for Active Directory |
| **WAN** | `10.30.30.0/24` (Security) | * | * | * | `WAN address` | * | Auto NAT for Security operations |
| **WAN** | `10.40.40.0/24` (Malware) | * | * | * | `WAN address` | * | (Conditional) NAT for Sandbox detonation |

---

## Port Forwarding (Inbound NAT Rules)

To expose internal services (such as a CTF Web server or Wazuh Agent listener) to external networks or upstream hosts:

| Interface | Proto | External Port | Target IP | Target Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **WAN** | TCP | `8443` | `10.30.30.10` | `443` | External HTTPS access to Wazuh SIEM Dashboard |
| **WAN** | TCP | `1514` | `10.30.30.10` | `1514` | Inbound Wazuh Agent Telemetry registration |
| **WAN** | TCP | `8080` | `10.10.10.50` | `80` | External access to Cyber Range Web Vulnerability target |

---

## WebGUI Configuration Steps

1. Navigate to **Firewall** -> **NAT**.
2. For Outbound NAT: Click **Outbound** tab -> Select **Hybrid Outbound NAT** -> Save.
3. For Port Forwarding: Click **Port Forward** tab -> Click **+ Add**.
   * Interface: `WAN`
   * Protocol: `TCP`
   * Destination port: `8443`
   * Redirect target IP: `10.30.30.10`
   * Redirect target port: `443`
   * Filter rule association: `Add associated filter rule`
4. Click **Save** and **Apply Changes**.
