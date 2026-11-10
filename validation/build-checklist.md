# Lab Build Checklist

Use this checklist as a completion record. Check an item only after you have
performed and verified it on the current lab build.

## Host and Network Foundation

- [ ] VirtualBox is installed on the Kali host.
- [ ] Host-only networking is configured with DHCP disabled.
- [ ] The five `intnet-*` networks use the names in the [IP plan](../architecture/ip-plan.md).
- [ ] The pfSense VM has the seven intended adapters attached.
- [ ] Adapter-to-interface mapping was verified by MAC address.

## Firewall and Shared Services

- [ ] pfSense installation and interface assignment are complete.
- [ ] Each internal interface has the planned address and subnet.
- [ ] Baseline firewall rules and aliases are applied.
- [ ] DHCP is enabled only on intended interfaces; MALWARE and HOST_MGMT are static by default.
- [ ] DNS scope and malware isolation were reviewed.
- [ ] A baseline pfSense configuration backup is stored securely.

## Segment Deployment

- [ ] Management workstation can reach the pfSense WebGUI.
- [ ] Cyber range targets are isolated on `intnet-cyber`.
- [ ] Active Directory DNS, domain membership, and endpoint logging are verified.
- [ ] Security monitoring receives the configured firewall and endpoint telemetry.
- [ ] Malware sandbox adapter, routing, and DNS isolation checks pass.

## Validation and Recovery

- [ ] Required positive and negative connectivity cases pass.
- [ ] Service-level checks pass for deployed components.
- [ ] No workload has an unintended bridged or NAT adapter.
- [ ] Clean snapshots exist for recoverable lab systems.
- [ ] Global [connectivity validation](connectivity.md) and relevant
  [troubleshooting checks](troubleshooting.md) are complete.
