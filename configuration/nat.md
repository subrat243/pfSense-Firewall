# Network Address Translation (NAT) & Port Forwarding

## Overview

Network Address Translation (NAT) maps private RFC1918 subnets (`10.0.0.0/8`) to external public/WAN IP addresses. pfSense handles both **Outbound NAT** (masquerading internal hosts for Internet access) and **Port Forwarding (Inbound NAT)**.

---

## Outbound NAT Configuration

pfSense defaults to **Automatic Outbound NAT rule generation**. For granular control over segmented subnets, **Hybrid** or **Manual Outbound NAT** rule generation is configured.

### Outbound NAT Rules Matrix

| Interface | Source Subnet | Source Port | Destination | Dest Port | NAT Address | NAT Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **WAN** | `10.0.0.0/24` (MGMT) | * | * | * | `WAN address` | * | Management updates, if permitted by firewall rules |
| **WAN** | `10.10.10.0/24` (CYBER) | * | * | * | `WAN address` | * | Optional target updates; pair with temporary scoped egress rules |
| **WAN** | `10.20.20.0/24` (AD) | * | * | * | `WAN address` | * | Optional controlled patching only |
| **WAN** | `10.30.30.0/24` (SECURITY) | * | * | * | `WAN address` | * | SIEM updates/feeds if needed |

Do not create an outbound NAT rule for `10.40.40.0/24` (MALWARE). NAT is not a firewall policy, but omitting it provides defense in depth; the MALWARE interface must also have no WAN pass rule. HOST_MGMT uses a private access subnet and does not need Internet NAT through pfSense.

---

## Port Forwarding (Inbound NAT Rules)

Do not forward pfSense GUI, SSH, Wazuh dashboard, agent ports, or vulnerable cyber targets from WAN. Remote administration uses WireGuard; the only pfSense WAN service opened is its UDP handshake port.

| Interface | Proto | External Port | Target IP | Target Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **WAN** | UDP | `51820` | `WAN address` | `51820` | WireGuard handshake only; not a pfSense port-forward target |

With pfSense WAN attached to VirtualBox NAT, configure a VirtualBox NAT port-forward on Adapter 1: UDP host port `51820` to the current pfSense WAN IP and guest port `51820`. If Kali is behind a home router and remote access is needed, forward UDP `51820` from that router to the physical Kali host as well. CGNAT prevents unsolicited inbound connections; use an outbound tunnel or public VPN endpoint instead.

Because this lab's pfSense WAN receives a private address from VirtualBox NAT, disable **Block private networks** on that WAN only if required for the forwarded handshake. Keep this protection enabled on a genuine public WAN.

---

## WebGUI Configuration Steps

1. Navigate to **Firewall** -> **NAT**.
2. For Outbound NAT: Click **Outbound** tab -> Select **Hybrid Outbound NAT** -> Save.
3. Review generated outbound rules and remove any rule covering MALWARE (`10.40.40.0/24`). Ensure egress is also allowed by the relevant interface firewall rules; NAT alone does not grant access.
4. On the pfSense VM's VirtualBox **Adapter 1 (NAT) → Advanced → Port Forwarding**, add UDP host port `51820` to the current pfSense WAN IP, guest port `51820`.
5. Under **Firewall → Rules → WAN**, add a pass rule for UDP `51820` to **WAN address**. Do not associate a redirect to an internal web dashboard.
6. If the physical Kali host is behind a home router, forward that router's UDP port `51820` to the Kali host. Save/apply and test from a genuinely external network.

<!-- minimal update -->
