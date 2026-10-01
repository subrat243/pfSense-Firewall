# Network Connectivity & Firewall Policy Validation Test Suite

## Overview

Run these tests from the stated source interface or VM. pfSense evaluates rules on ingress, and tests from Kali must use the correct HOST_MGMT, BLACKBOX, or WireGuard route. Do not use source spoofing as a substitute for testing an actual segment.

---

## Inter-VLAN Connectivity Test Matrix

| Source | Destination | Test | Expected result |
| :--- | :--- | :--- | :--- |
| Management VM (`10.0.0.10`) | CYBER/AD/SECURITY/MALWARE hosts | Required management service | Pass only per MGMT policy |
| Physical Kali via HOST_MGMT (`192.168.56.1`) | Each `10.x` gateway and selected lab host | `ping` / service test | Pass through `192.168.56.2` |
| CYBER VM (`10.10.10.x`) | AD (`10.20.20.x`) | `nc -zv 10.20.20.10 445` | Block unless temporary pivot rule is enabled |
| CYBER VM | MGMT or MALWARE | `ping`/service test | Block |
| CYBER VM | SIEM (`10.30.30.10`) | Test only configured syslog/Wazuh/Beats ports | Pass to collector only; other ports blocked |
| AD VM (`10.20.20.x`) | SIEM (`10.30.30.10`) | Test configured ingest port | Pass only to collector and configured port |
| AD VM | CYBER or MALWARE | `ping`/service test | Block |
| MALWARE VM (`10.40.40.x`) | WAN and other routed segments | `ping`/service/DNS test | Block; fake DNS stays local to malware segment |
| BLACKBOX Kali (`192.168.100.10`) | CYBER (`10.10.10.0/24`) | `nmap -Pn 10.10.10.0/24` | Reachable targets only |
| BLACKBOX Kali | MGMT/AD/SECURITY/MALWARE | `nmap -Pn <subnet>` | No reachable hosts; scan routes must use `192.168.100.1` |
| WireGuard peer (`10.50.50.2`) | `10.0.0.1:443`, `10.0.0.10:22`, `10.30.30.10:443` | `nc -zv <host> <port>` | Pass only for configured allow rules |
| WireGuard peer | CYBER/AD/MALWARE or unlisted service ports | `nc -zv <host> <port>` | Block |

Do not expect ICMP to pass over WireGuard unless a separate ICMP rule was deliberately added. Internet egress is not a universal pass: enable and test it only for segments with explicit firewall and NAT policy.

### Access-mode checks

Use [Kali Host Network Setup](../installation/kali-network-setup.md) to switch modes. In HOST_MGMT mode, verify `ip route get 10.30.30.10` uses `192.168.56.2`. In BLACKBOX mode, verify it uses `192.168.100.1` and that the HOST_MGMT profile is disconnected. Protected-range scans must travel through pfSense BLACKBOX so they test firewall denies, not Kali's default Internet route.

For WireGuard, test from an external network and confirm `sudo wg` shows a recent handshake. Then test only the listed allowed services and at least one unlisted destination/port.

---

## Stateful Firewall Log Inspection

To inspect dropped connection attempts in real-time on pfSense console:

```bash
# SSH into pfSense or open Console Shell (Option 8)
clog -f /var/log/filter.log | grep "block"
```

<!-- minimal update -->
