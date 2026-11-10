# Management Enclave

**Network:** `intnet-mgmt` · **Subnet:** `10.0.0.0/24` · **Gateway:** `10.0.0.1`

The management enclave is for administrative workstations and firewall access. Do
not place intentionally vulnerable workloads on this network.

## Deployment

1. Complete [VirtualBox networking](../installation/virtualbox.md),
   [pfSense installation](../installation/pfsense-install.md), and
   [interface assignment](../installation/interface-assignment.md).
2. Confirm the pfSense `MGMT` interface is enabled as `10.0.0.1/24`.
3. Create an Ubuntu management VM (the project baseline is 2 vCPU, 2 GB RAM, and
   25 GB disk) and attach its only adapter to `intnet-mgmt`.
4. Assign `10.0.0.10/24` statically, with gateway and DNS `10.0.0.1`. Keep static
   infrastructure addresses outside the DHCP pool in the
   [IP plan](../architecture/ip-plan.md).
5. From this workstation, open `https://10.0.0.1` and complete the pfSense
   configuration. Save a configuration backup before making policy changes.

## Configuration

- Permit management access only from approved administrative hosts. Review the
  `MGMT` policy in [Firewall Rules](../configuration/firewall-rules.md); avoid
  adding broad access rules to other interfaces to compensate for a missing
  management rule.
- Configure DHCP only if desired for additional management clients. The documented
  pool is `10.0.0.100–10.0.0.200`; keep `.1` and `.10` reserved.
- Use the dedicated HOST_MGMT path for administration from the physical Kali host.
  Follow [Kali host network setup](../installation/kali-network-setup.md); never
  connect Kali directly to an internal lab network.

## Validate

- From the management VM, confirm `10.0.0.1` responds and the HTTPS WebGUI loads.
- Test each required management service against the relevant host, then verify
  that the matching firewall rule is limited to the intended source and port.
- Run the management cases in [Connectivity Validation](../validation/connectivity.md).

## Troubleshooting

| Symptom | Check | Resolution |
| :--- | :--- | :--- |
| WebGUI at `https://10.0.0.1` times out | VM adapter network and client address | Attach to `intnet-mgmt`, confirm `10.0.0.0/24`, and check the `MGMT` interface is enabled. |
| Management VM reaches its gateway but not another segment | Ingress rule on `MGMT` and the target host's route | Add only the required administrative access in the `MGMT` policy; check the target interface and host firewall. |
| DHCP client has no lease | DHCP service status, selected interface, and pool bounds | Follow the `MGMT` steps in the [DHCP guide](../installation/dhcp.md); keep static addresses outside the pool. |
| Physical Kali cannot reach the firewall | `vboxnet0`, HOST_MGMT address, and route | Follow the dedicated [Kali troubleshooting steps](../installation/kali-network-setup.md) and [global troubleshooting guide](../validation/troubleshooting.md). |
