# pfSense Segmented Cybersecurity Lab

This repository documents an isolated VirtualBox lab hosted on Kali Linux. pfSense
routes and filters traffic between five internal training networks. This README is
the quick overview and documentation index; detailed procedures live in the guides
linked below.

> **Isolation first:** Keep vulnerable targets and malware-analysis guests on their
> assigned VirtualBox internal networks. Do not bridge them to a physical network
> or expose them through WAN port forwarding. Verify the malware sandbox's
> no-egress policy before use.

## Architecture at a Glance

![Home lab network architecture](assets/home_lab_network_architecture.png)

Kali is the physical host, not a lab VM. VirtualBox runs pfSense and the guest
systems. Five `intnet-*` networks provide the lab segments; a separate host-only
network (`vboxnet0`) is the trusted administration path from Kali to pfSense.

| Network | VirtualBox attachment | Subnet | pfSense address | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| WAN | NAT | DHCP | Upstream-assigned | Controlled upstream access |
| Management | `intnet-mgmt` | `10.0.0.0/24` | `10.0.0.1` | Administration and WebGUI |
| Cyber range | `intnet-cyber` | `10.10.10.0/24` | `10.10.10.1` | Isolated training targets |
| Active Directory | `intnet-ad` | `10.20.20.0/24` | `10.20.20.1` | Windows domain lab |
| Security operations | `intnet-sec` | `10.30.30.0/24` | `10.30.30.1` | SIEM and log collection |
| Malware sandbox | `intnet-malware` | `10.40.40.0/24` | `10.40.40.1` | Quarantined analysis |
| HOST_MGMT | `vboxnet0` | `192.168.56.0/24` | `192.168.56.2` | Trusted Kali administration |

For interface mapping, complete address allocations, and design decisions, see
[Architecture](architecture/design-rationale.md) and the
[IP allocation plan](architecture/ip-plan.md).

## Recommended Build Steps

Follow the sequence below. Each guide includes prerequisites and a next step.

| Step | Work | Guide |
| :---: | :--- | :--- |
| 1 | Review topology, trust boundaries, and IP assignments | [Design rationale](architecture/design-rationale.md) · [IP plan](architecture/ip-plan.md) |
| 2 | Create VirtualBox host-only networking and prepare the Kali access path | [VirtualBox provisioning](installation/virtualbox.md) · [Kali network setup](installation/kali-network-setup.md) |
| 3 | Provision and install pfSense; map and configure its interfaces | [VM provisioning](installation/virtualbox.md) · [pfSense installation](installation/pfsense-install.md) · [Interface assignment](installation/interface-assignment.md) |
| 4 | Set up DHCP, aliases, DNS, firewall policy, and NAT as required | [DHCP](installation/dhcp.md) · [Aliases](configuration/aliases.md) · [DNS](configuration/dns-resolver.md) · [Firewall rules](configuration/firewall-rules.md) · [NAT](configuration/nat.md) |
| 5 | Deploy each workload only after its network policy is in place | [Segment guides](segments/README.md) |
| 6 | Test allowed and blocked paths, then save a verified baseline | [Connectivity validation](validation/connectivity.md) · [Build checklist](validation/build-checklist.md) |

## Segment Runbooks

Each runbook has dedicated deployment, configuration, validation, and
troubleshooting sections for that network.

| Section | Guide | Troubleshooting |
| :--- | :--- | :--- |
| Management enclave | [Management](segments/management.md) | [Management issues](segments/management.md#troubleshooting) |
| Cyber range and DMZ | [Cyber range](segments/cyber-range.md) | [Cyber range issues](segments/cyber-range.md#troubleshooting) |
| Active Directory lab | [Active Directory](segments/active-directory.md) | [AD issues](segments/active-directory.md#troubleshooting) |
| Security operations and SIEM | [Security operations](segments/security-operations.md) | [SIEM issues](segments/security-operations.md#troubleshooting) |
| Malware analysis sandbox | [Malware sandbox](segments/malware-sandbox.md) | [Sandbox issues](segments/malware-sandbox.md#troubleshooting) |

## Shared Guides

| Topic | Documentation |
| :--- | :--- |
| Topology and addressing | [Architecture rationale](architecture/design-rationale.md) · [IP plan](architecture/ip-plan.md) |
| Host and firewall installation | [VirtualBox](installation/virtualbox.md) · [pfSense install](installation/pfsense-install.md) · [Interface assignment](installation/interface-assignment.md) · [Kali access](installation/kali-network-setup.md) · [HOST_MGMT routing script](installation/lab-trusted.sh) |
| Network configuration | [DHCP scopes](installation/dhcp.md) · [Firewall aliases](configuration/aliases.md) · [Firewall rule matrix](configuration/firewall-rules.md) · [NAT](configuration/nat.md) · [DNS resolver](configuration/dns-resolver.md) |
| Verification and recovery | [Connectivity tests](validation/connectivity.md) · [Build checklist](validation/build-checklist.md) · [Global troubleshooting](validation/troubleshooting.md) |
| Product sources | [Component reference](reference/components.md) |

## Repository Layout

```text
architecture/   Topology, design rationale, and IP plan
installation/   VirtualBox, Kali, pfSense, interface, DHCP, and HOST_MGMT helper
configuration/  Firewall rules, aliases, NAT, and DNS
segments/       Per-network deployment and troubleshooting runbooks
validation/     Connectivity, build checklist, and global troubleshooting
reference/      Component and official download sources
assets/         Diagrams and installation screenshots
backup/         Reference pfSense configuration
```

The [MIT License](LICENSE) applies to this repository. Product names and downloads
remain subject to their respective owners' terms.
