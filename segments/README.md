# Lab Segment Guides

Each guide covers the purpose, deployment sequence, configuration, validation, and
segment-specific troubleshooting for one lab network. Build the firewall and its
baseline policies before attaching workloads.

| Segment | Subnet | Guide |
| :--- | :--- | :--- |
| Management enclave | `10.0.0.0/24` | [Management](management.md) |
| Cyber range and DMZ | `10.10.10.0/24` | [Cyber range](cyber-range.md) |
| Active Directory lab | `10.20.20.0/24` | [Active Directory](active-directory.md) |
| Security operations | `10.30.30.0/24` | [Security operations](security-operations.md) |
| Malware analysis sandbox | `10.40.40.0/24` | [Malware sandbox](malware-sandbox.md) |

## Shared References

- [Architecture rationale](../architecture/design-rationale.md)
- [IP allocation plan](../architecture/ip-plan.md)
- [Firewall rules and traffic policy](../configuration/firewall-rules.md)
- [Aliases](../configuration/aliases.md)
- [DHCP scopes](../installation/dhcp.md)
- [Connectivity tests](../validation/connectivity.md)
- [Global troubleshooting](../validation/troubleshooting.md)

## Build Order

1. Establish the topology and address plan.
2. Configure VirtualBox networks and the pfSense VM.
3. Install pfSense, map interfaces, and apply baseline isolation rules.
4. Configure shared services such as DNS and DHCP.
5. Deploy each segment using its guide; validate before moving to the next.
6. Run the global connectivity checks and save a known-good configuration backup.

Do not treat the segment guides as permission to expose lab services to a physical
or public network. Keep vulnerable systems on their assigned internal networks.
