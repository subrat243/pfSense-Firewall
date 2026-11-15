# Stateful Firewall Rules & Security Policy Matrix

## Overview

pfSense processes firewall rules **top-to-bottom, first-match-wins**, and evaluates them on the interface where a connection **enters** pfSense. Rules are stateful: once a connection is allowed, return traffic is permitted by the state table.

## Related Documentation

- [Repository overview](../README.md)
- [Architecture rationale](../architecture/design-rationale.md)
- [IP allocation plan](../architecture/ip-plan.md)
- [Interface assignment guide](../installation/interface-assignment.md)
- [Firewall aliases](aliases.md)
- [NAT & port forwarding](nat.md)
- [Connectivity validation](../validation/connectivity.md)

---

## Global Firewall Principles

1. **Default deny**: each interface has an implicit deny at the bottom. Add only the pass rules a segment needs.
2. **Ingress evaluation**: a Cyber-to-AD policy belongs on CYBER, not AD.
3. **Management**: MGMT administers the lab. HOST_MGMT is a separate, one-way path from the physical Kali host; nothing in the lab may initiate connections to it.
4. **Protect the firewall itself**: every segment that is not an admin segment gets no access to `This Firewall` except DNS.
5. **Malware containment**: MALWARE has no WAN or cross-segment pass rule. Keep the blocks explicit and logged.
6. **SIEM telemetry**: allow only source-to-collector ports, above any broader block.
7. **Logging**: enable logging on every block rule.
8. **Optional rules** (updates, pivot drills) stay disabled until needed.

## Required Aliases

All rules below reference aliases instead of raw IPs and ports. Create them first, exactly as named in [aliases.md](aliases.md).

---

## Interface Rule Matrices

### 1. MGMT (`em1`)

| # | Action | Proto | Source | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass | TCP | `Admin_Hosts` | This Firewall | `Management_Ports` | Approved admins reach WebGUI/SSH |
| 2 | Pass | TCP/UDP | `MGMT_NET` | This Firewall | `53` | Management DNS |
| 3 | Block | * | `MGMT_NET` | This Firewall | * | Stop access through other interface IPs |
| 4 | Block | * | `MGMT_NET` | `HOST_MGMT_NET` | * | Keep the Kali link one-way |
| 5 | Pass | * | `MGMT_NET` | `Internal_Lab_Subnets` | * | Administer lab segments |
| 6 | Pass | TCP | `MGMT_NET` | `! RFC1918_Networks` | `Web_Ports` | Package updates |

Delete the default IPv6 "LAN to any" rule if IPv6 is unused. Disable the anti-lockout rule (System → Advanced → Admin Access) only after HOST_MGMT access is confirmed, otherwise any MGMT host can still reach the WebGUI and rule 1 restricts nothing.

### 2. CYBER / DMZ (`em2`)

DMZ systems are presumed compromised and may never initiate connections into protected networks.

| # | Action | Proto | Source | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass | TCP/UDP | `CYBER_NET` | CYBER address | `53` | DNS (disable if targets do not need it) |
| 2 | Pass | UDP | `CYBER_NET` | `SIEM_Collectors` | `514` | Syslog |
| 3 | Pass | TCP | `CYBER_NET` | `SIEM_Collectors` | `SIEM_Agent_Ports` | Wazuh / Beats |
| 4 | Pass (disabled) | TCP/UDP | `CYBER_NET` | `! RFC1918_Networks` | `Web_Ports` | Updates, enable only when patching |
| 5 | Pass (disabled) | TCP/UDP | `CYBER_NET` | `Domain_Controllers` | `ActiveDirectory_Ports` | Controlled pivot drill only |
| 6 | Block | * | `CYBER_NET` | `MGMT_NET` | * | Protect management plane |
| 7 | Block | * | `CYBER_NET` | `MALWARE_NET` | * | Protect malware sandbox |
| 8 | Block | * | `CYBER_NET` | `SECURITY_NET` | * | Only telemetry (rules 2-3) gets through |

Never leave rule 5 enabled permanently.

### 3. AD (`em3`)

| # | Action | Proto | Source | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass | TCP | `AD_NET` | `SIEM_Collectors` | `SIEM_Agent_Ports` | Windows log forwarding |
| 2 | Pass (optional) | TCP/UDP | `Domain_Controllers` | This Firewall | `53` | DC DNS forwarding, only if used |
| 3 | Block | * | `AD_NET` | `CYBER_NET` | * | AD must not reach the attack range |
| 4 | Block | * | `AD_NET` | `MALWARE_NET` | * | Protect malware sandbox |
| 5 | Pass (disabled) | TCP | `Domain_Controllers` | `! RFC1918_Networks` | `Web_Ports` | Patching only |

AD clients use the domain controller (`10.20.20.10`) for DNS; that same-subnet traffic does not traverse pfSense.

### 4. SECURITY (`em4`)

| # | Action | Proto | Source | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass | TCP/UDP | `SECURITY_NET` | This Firewall | `53` | DNS |
| 2 | Pass | TCP/UDP | `SECURITY_NET` | `SIEM_Poll_Targets` | Required ports | Active polling, scoped to specific hosts |
| 3 | Pass | TCP | `SECURITY_NET` | `! RFC1918_Networks` | `Web_Ports` | Threat intel and rule updates |

Do not poll all of `Internal_Lab_Subnets`; that would give the sandbox a path into the SIEM network. Passive Suricata/Zeek capture needs no rule, only VirtualBox promiscuous mode or traffic mirroring.

### 5. MALWARE (`em5`)

| # | Action | Proto | Source | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass (optional) | TCP/UDP | `MALWARE_NET` | Fake-DNS host in segment | `53` | INetSim / FakeNet-NG only |
| 2 | Block | * | `MALWARE_NET` | This Firewall | * | No access to pfSense |
| 3 | Block | * | `MALWARE_NET` | `Internal_Lab_Subnets`, `HOST_MGMT_NET`, `WG_REMOTE_NET` | * | No lateral movement |
| 4 | Block | * | `MALWARE_NET` | any | * | **Critical: no Internet egress** |

No NAT rule, no public DNS exception, and no second malware VM NIC on NAT/bridged networking. Transfer samples only by controlled read-only media or a quarantined workflow.

### 6. HOST_MGMT (`em6`*)

| # | Action | Proto | Source | Destination | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass | * | `192.168.56.1/32` | any | Administrative channel for physical Kali |

Static host address `192.168.56.1`, pfSense address `192.168.56.2/24`. This is the recovery path: keep it working before tightening MGMT.

\* `em6` is an example; verify interface mapping by MAC address.

### 7. WAN

| # | Action | Proto | Source | Destination | Port | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass | UDP | any | WAN address | `51820` | WireGuard handshake only |

Do not expose the GUI, SSH, or dashboards on WAN. When WAN uses VirtualBox NAT/private addressing, disable **Block private networks** on this isolated lab WAN only. Keep it enabled on a genuine public WAN. See [NAT and port forwarding](nat.md) for the required port forwards.

### 8. WireGuard Remote Access (`WG_REMOTE`)

Assign the tunnel under **Interfaces → Assignments** with `10.50.50.1/24`; a remote peer may use `10.50.50.2/32`.

| # | Action | Proto | Source | Destination | Port | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Pass | TCP | `10.50.50.2/32` | `10.0.0.1` | `443` | pfSense WebGUI |
| 2 | Pass | TCP | `10.50.50.2/32` | `10.0.0.10` | `22` | Management Ubuntu SSH |
| 3 | Pass | TCP | `10.50.50.2/32` | `10.30.30.10` | `443` | Wazuh dashboard |
| 4 | Pass (optional) | TCP | `10.50.50.2/32` | `10.30.30.10` | `22` | Wazuh administration, only if needed |

Do not add `WG_REMOTE -> any`. Client `AllowedIPs = 10.0.0.0/24, 10.30.30.0/24, 10.50.50.0/24` for split tunneling. If the ISP uses CGNAT, inbound forwarding will not work; use an outbound tunnel or public VPN endpoint instead.

---

## Traffic Flow Summary

| Flow | Result | Rule |
| :--- | :--- | :--- |
| Kali → any lab host | Allowed; replies via state table | HOST_MGMT 1 |
| Any lab host → Kali | Blocked | MGMT 4, MALWARE 3, implicit deny elsewhere |
| Admin VM → lab subnets | Allowed | MGMT 5 |
| Non-admin MGMT host → pfSense GUI | Blocked (once anti-lockout is off) | MGMT 3 |
| CYBER target → Wazuh agent ports | Allowed, collector IPs only | CYBER 2-3 |
| CYBER target → SECURITY (other ports) | Blocked | CYBER 8 |
| CYBER target → DC | Dropped (pivot rule disabled) | Implicit deny |
| Malware sample → anywhere | Blocked and logged | MALWARE 2-4 |
| Remote peer via WireGuard | Only the three listed services | WG_REMOTE 1-3 |

## Rollout Checklist

1. Create all aliases.
2. Add the new rules below the existing ones and test each flow.
3. Remove the old rules, then disable anti-lockout.
4. Change the default `pfsense` password.
5. Confirm blocks appear in **Status → System Logs → Firewall**.
