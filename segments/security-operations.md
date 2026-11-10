# Security Operations and SIEM

**Network:** `intnet-sec` · **Subnet:** `10.30.30.0/24` · **Gateway:** `10.30.30.1`

This segment hosts centralized monitoring and log collection. The collector should
receive only explicitly configured telemetry; do not make its administration
interfaces generally reachable from the training networks.

## Deployment

1. Configure the `SECURITY` interface and its ingress policy.
2. Deploy the selected Wazuh or Security Onion stack at `10.30.30.10/24` on
   `intnet-sec`. Size the VM for the chosen product and expected event volume.
3. Set its gateway to `10.30.30.1`, configure time synchronization, and restrict
   administrative access to approved management hosts.
4. Enable and test the collector listeners before enrolling endpoints.
5. Configure pfSense remote syslog under **Status → System Logs → Settings**.
   Send firewall events to `10.30.30.10:514` and select only the log categories
   required for the lab.
6. Enroll agents from the Cyber Range and AD networks. Configure only the required
   event channels and destinations.

## Configuration

| Source | Destination | Protocol/port | Purpose |
| :--- | :--- | :--- | :--- |
| pfSense | `10.30.30.10` | UDP `514` | Remote syslog |
| Cyber Range endpoints | `10.30.30.10` | TCP `1514`, `1515`, and/or `5044` | Agent or Beats telemetry, as configured |
| AD endpoints | `10.30.30.10` | TCP `1514`, `1515`, and/or `5044` | Agent or Beats telemetry, as configured |

Confirm actual listeners and protocols for the selected SIEM before creating rules;
the listed ports are not interchangeable. Apply the source-specific rules in
[Firewall Rules](../configuration/firewall-rules.md). Avoid exposing dashboards,
SSH, indexer APIs, or other management services to workload segments.

## Validate

- Send a test syslog event from pfSense and confirm it appears in the collector.
- Confirm an enrolled endpoint is active and its selected events are indexed.
- From each source segment, test only its configured telemetry endpoint/port.
- Confirm unapproved ports and management services remain blocked.
- Use the end-to-end checks in [Connectivity Validation](../validation/connectivity.md).

## Troubleshooting

| Symptom | Check | Resolution |
| :--- | :--- | :--- |
| No pfSense logs arrive | Remote syslog destination, selected categories, UDP listener, and routing | Confirm the collector listens on UDP `514`, then check the SECURITY host and firewall logs. |
| Agent is disconnected or not enrolled | Endpoint service, enrollment status, collector listener, and source-specific rule | Correct the configured agent destination and permit only the required enrollment/event ports. |
| Dashboard loads but shows no events | Time range, indexing/ingest pipeline, and event source configuration | Check collector health and endpoint input configuration before widening any firewall rule. |
| SIEM VM cannot download updates | SECURITY egress policy, WAN gateway, and outbound NAT | Allow only required update egress and review [NAT configuration](../configuration/nat.md); do not add a blanket WAN rule. |
| Telemetry ports work from an unintended segment | Rule source scope and aliases | Restrict the source to the intended segment/hosts and inspect active states. |

For general firewall and gateway diagnostics, see
[Troubleshooting](../validation/troubleshooting.md).
