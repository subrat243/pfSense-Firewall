# Cyber Range and DMZ

**Network:** `intnet-cyber` · **Subnet:** `10.10.10.0/24` · **Gateway:** `10.10.10.1`

This network contains deliberately vulnerable targets for authorized, isolated
training. Keep its systems on `intnet-cyber`; do not bridge them to a physical
network or expose their services through WAN port forwarding.

## Deployment

1. Confirm the `CYBER` interface and its baseline rules are configured in
   [Interface Assignment](../installation/interface-assignment.md) and
   [Firewall Rules](../configuration/firewall-rules.md).
2. Deploy only the target VMs needed for the exercise. The project address plan
   reserves:

   | System | Address |
   | :--- | :--- |
   | Metasploitable 2 | `10.10.10.10` |
   | Metasploitable 3 | `10.10.10.20` |
   | OWASP Juice Shop | `10.10.10.30` |
   | DVWA | `10.10.10.31` |
   | SafeLine WAF | `10.10.10.50` |

3. Attach each target to the `intnet-cyber` internal network only. Use static
   addresses or the documented CYBER DHCP scope without overlapping reservations.
4. For a WAF exercise, deploy SafeLine on a dedicated VM at `.50`, install it from
   its official distribution instructions, and configure reverse-proxy backends
   for selected web targets. Use strong, unique secrets and restrict its management
   listener to approved administrators.
5. For Windows telemetry exercises on Metasploitable 3, use a compatible Sysmon
   release and a reviewed configuration. Configure its agent to send only the
   required telemetry to the SIEM; allow that traffic through the CYBER policy.

## Configuration

- Follow the CYBER ingress matrix in [Firewall Rules](../configuration/firewall-rules.md).
  Keep the default policy restrictive; enable temporary cross-segment access only
  for a scoped, authorized exercise and remove it afterward.
- Telemetry destinations and ports must match the SIEM configuration in
  [Security Operations](security-operations.md). Do not enable general access to
  the SIEM network.
- If target updates are required, allow only the required egress temporarily and
  review [NAT policy](../configuration/nat.md). NAT alone does not permit traffic.
- Use [Aliases](../configuration/aliases.md) for shared destinations and ports
  rather than duplicating inconsistent address literals.

## Validate

- Confirm each target has the intended address, gateway, and `intnet-cyber`
  attachment.
- Verify telemetry reaches the configured collector and that unapproved
  destinations remain blocked.
- Confirm WAF-protected applications are reachable through the proxy and that its
  management listener is not available from ordinary range hosts.
- Run the CYBER cases in [Connectivity Validation](../validation/connectivity.md).

## Troubleshooting

| Symptom | Check | Resolution |
| :--- | :--- | :--- |
| Target is unreachable from the management workstation | Target network attachment, IP/mask, gateway, and MGMT ingress policy | Attach it to `intnet-cyber`, check for address conflicts, and permit only the required management service. |
| Target can reach the SIEM but no events arrive | Agent/service status, collector address, protocol/port, and SIEM listener | Verify the endpoint configuration and corresponding narrow CYBER-to-SIEM rule; inspect collector-side logs. |
| WAF dashboard is unavailable | SafeLine service health, VM address, port, and source restriction | Check the VM's local service logs and permit the dashboard only from approved admin hosts. |
| Proxy responds but the application does not | Backend address/port and target service health | Test the backend from the WAF VM and correct the proxy route or target service. |
| A temporary exercise rule still allows traffic | Rule order and active firewall states | Remove or disable the temporary rule, apply changes, and clear only the matching stale state. |

For general interface, routing, and rule diagnostics, see
[Troubleshooting](../validation/troubleshooting.md).
