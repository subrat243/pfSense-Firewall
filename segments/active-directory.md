# Active Directory Lab

**Network:** `intnet-ad` · **Subnet:** `10.20.20.0/24` · **Gateway:** `10.20.20.1`

This segment contains the isolated Windows domain and its member workstations.
Domain services should be reachable only where explicitly required by the firewall
policy.

## Deployment

1. Configure the `AD` interface and its ingress rules. Use the
   [IP plan](../architecture/ip-plan.md) to avoid collisions.
2. Deploy a Windows Server evaluation VM on `intnet-ad` and assign DC01
   `10.20.20.10/24`. Set its gateway to `10.20.20.1` and DNS to loopback during
   initial domain-controller setup.
3. Rename the server to `DC01`, install Active Directory Domain Services and DNS,
   and promote it as a new forest named `lab.local`. Store the recovery credentials
   securely and reboot after promotion.
4. Create only the users, groups, organizational units, and service accounts
   required for a controlled lab exercise. Use non-production credentials.
5. Attach Windows member clients to `intnet-ad`, set their DNS server to
   `10.20.20.10`, and join them to `lab.local`.
6. Install endpoint telemetry agents on DC01 and member clients. Send events only
   to the approved collector, `10.30.30.10`, using the corresponding rules in
   [Firewall Rules](../configuration/firewall-rules.md).

## Configuration

- AD clients must query DC01 for domain DNS. Configure the AD DHCP scope to
  advertise `10.20.20.10`; do not substitute a public DNS server. See
  [DHCP Scopes](../installation/dhcp.md) and
  [DNS Resolver](../configuration/dns-resolver.md).
- Keep inbound and outbound cross-segment access explicit. In particular, do not
  permit unrestricted AD-to-CYBER or AD-to-MALWARE traffic.
- Enable the Windows audit categories and Sysmon configuration needed by the
  exercise, then configure the agent to forward the selected events to the SIEM.
- Take a pfSense configuration backup before firewall changes and a clean VM
  snapshot before substantial domain changes.

## Validate

- On a domain client, confirm DNS resolves `DC01` and the domain's service records.
- Confirm the client reports the expected domain controller and domain membership.
- Verify a test endpoint event appears at the SIEM and that unrelated destinations
  remain blocked.
- Run the AD cases in [Connectivity Validation](../validation/connectivity.md).

## Troubleshooting

| Symptom | Check | Resolution |
| :--- | :--- | :--- |
| Domain join cannot find `lab.local` | Client DNS settings and DC01 DNS service | Set client DNS to `10.20.20.10`, confirm DC01 is reachable, and verify the AD DNS zone exists. |
| Domain join reports a time or authentication error | Client/DC time synchronization and credentials | Synchronize time with the domain controller and retry using an authorized lab account. |
| Client locates DC01 but cannot complete domain operations | Required AD ports, host firewall, and AD ingress rule | Permit only the required domain-service ports from the appropriate AD clients; consult the AD policy and alias tables. |
| Events are missing from the SIEM | Agent state, event-channel selection, collector listener, and AD-to-SIEM rule | Check the agent and collector logs and confirm the configured destination is `10.30.30.10`. |
| Other segments unexpectedly reach domain services | Firewall rule scope and state table | Narrow the source/destination policy and remove matching stale states after applying the corrected rule. |

For shared routing and DNS diagnostics, see
[Troubleshooting](../validation/troubleshooting.md).
