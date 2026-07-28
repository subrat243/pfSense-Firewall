# Firewall Aliases Reference Guide

## Overview

pfSense **Aliases** simplify complex firewall rule tables by grouping IP addresses, subnets, ports, or hostnames into reusable symbolic names. Modifying an alias automatically updates all associated firewall rules.

---

## Defined Aliases Matrix

### 1. Host Aliases

| Alias Name | Type | Contents | Description |
| :--- | :--- | :--- | :--- |
| `Admin_Hosts` | Host(s) | `10.0.0.10`, `10.0.0.15` | Workstations permitted to access pfSense WebGUI and SSH |
| `Domain_Controllers` | Host(s) | `10.20.20.10`, `10.20.20.11` | Windows Active Directory Domain Controllers |
| `SIEM_Collectors` | Host(s) | `10.30.30.10`, `10.30.30.20` | Wazuh and Log Management Servers |

### 2. Network Aliases

| Alias Name | Type | Contents | Description |
| :--- | :--- | :--- | :--- |
| `RFC1918_Networks` | Network(s) | `10.0.0.0/8`<br>`172.16.0.0/12`<br>`192.168.0.0/16` | All private non-routable IPv4 address space |
| `Internal_Lab_Subnets` | Network(s) | `10.0.0.0/24`<br>`10.10.10.0/24`<br>`10.20.20.0/24`<br>`10.30.30.0/24`<br>`10.40.40.0/24` | All segmented lab subnets |
| `Isolated_Subnets` | Network(s) | `10.40.40.0/24` | Networks blocked from all inter-VLAN routing |

### 3. Port Aliases

| Alias Name | Type | Contents / Ports | Description |
| :--- | :--- | :--- | :--- |
| `Management_Ports` | Port(s) | `22` (SSH), `443` (HTTPS) | WebGUI and SSH administrative service ports |
| `ActiveDirectory_Ports` | Port(s) | `53` (DNS), `88` (Kerberos), `135` (RPC), `139`/`445` (SMB), `389`/`636` (LDAP/S), `3268`/`3269` (GC) | Complete Windows Active Directory service port group |
| `SIEM_Ingest_Ports` | Port(s) | `514` (Syslog), `1514` (Wazuh Agent), `1515` (Wazuh Auth), `9200` (Elasticsearch) | Log and telemetry ingestion ports |
| `Web_Ports` | Port(s) | `80` (HTTP), `443` (HTTPS) | Standard web traffic |

---

## WebGUI Configuration Steps

1. Go to **Firewall** -> **Aliases**.
2. Click **+ Add** under the appropriate tab (**IP**, **Ports**, **URLs**).
3. Enter Name, Description, and list entries.
4. Click **Save** and **Apply Changes**.
