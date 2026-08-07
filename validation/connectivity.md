# Network Connectivity & Firewall Policy Validation Test Suite

## Overview

This document provides automated and manual verification procedures to ensure inter-VLAN routing, stateful packet filtering, NAT outbound Internet access, and DNS resolution function strictly according to design.

---

## Inter-VLAN Connectivity Test Matrix

| Source Subnet | Target Subnet | Protocol / Port | Expected Result | Rationale / Policy |
| :--- | :--- | :--- | :--- | :--- |
| **Management (`10.0.0.10`)** | `10.0.0.1` (pfSense) | TCP 443 / 22 | **PASS** | Allowed by Rule 1 (WebGUI / SSH access) |
| **Management (`10.0.0.10`)** | `10.10.10.10` (Cyber) | ICMP / Ping | **PASS** | Management allowed to manage Cyber hosts |
| **Management (`10.0.0.10`)** | `10.20.20.10` (AD) | TCP 389 (LDAP) | **PASS** | Management allowed full internal access |
| **Cyber Range (`10.10.10.10`)**| `10.0.0.10` (Mgmt) | ICMP / Ping | **FAIL (Blocked)** | Cyber Range blocked from Management network |
| **Cyber Range (`10.10.10.10`)**| `10.20.20.10` (AD) | TCP 445 (SMB) | **PASS** | Cyber Range allowed access to AD targets |
| **Active Dir. (`10.20.20.10`)**| `10.0.0.10` (Mgmt) | TCP 443 | **FAIL (Blocked)** | AD blocked from reaching Management hosts |
| **Malware (`10.40.40.10`)** | `10.0.0.10` (Mgmt) | ICMP / Ping | **FAIL (Blocked)** | **CRITICAL: Sandbox isolated** |
| **Malware (`10.40.40.10`)** | `10.10.10.10` (Cyber) | ICMP / Ping | **FAIL (Blocked)** | **CRITICAL: Sandbox isolated** |
| **Any Internal Subnet** | `8.8.8.8` / Internet | ICMP / TCP 80 | **PASS** | Outbound NAT internet egress permitted |

---

## Verification Test Script

Run this script on a test host in each subnet to validate security enforcement:

```bash
#!/usr/bin/env bash
# Network Connectivity Validation Script

TARGETS=(
    "10.0.0.1:443:pfSense WebGUI"
    "10.0.0.10:22:Management Host"
    "10.10.10.1:53:Cyber Gateway DNS"
    "10.20.20.10:389:Active Directory LDAP"
    "10.30.30.10:514:Security SIEM Syslog"
    "10.40.40.10:80:Malware Sandbox"
    "1.1.1.1:53:Public Internet DNS"
)

echo "=== Running pfSense Firewall Verification Suite ==="
for entry in "${TARGETS[@]}"; do
    IFS=":" read -r ip port desc <<< "$entry"
    if nc -z -w 2 "$ip" "$port" 2>/dev/null; then
        echo -e "[\e[32mREACHABLE\e[0m] $ip:$port -> $desc"
    else
        echo -e "[\e[31mBLOCKED\e[0m]   $ip:$port -> $desc"
    fi
done
```

---

## Stateful Firewall Log Inspection

To inspect dropped connection attempts in real-time on pfSense console:

```bash
# SSH into pfSense or open Console Shell (Option 8)
clog -f /var/log/filter.log | grep "block"
```

<!-- minimal update -->
