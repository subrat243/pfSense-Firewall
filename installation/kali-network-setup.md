# Kali Host Network Setup

## Purpose

Kali is the physical VirtualBox host, not a lab VM. Its host-only connection provides a dedicated, isolated management and administration path through pfSense:

- **HOST_MGMT** (`vboxnet0`) is the trusted administration path to pfSense and the five lab segments.

Do not connect Kali directly to any `intnet-*` lab network. Create the host-only network before provisioning pfSense; the setup expects `vboxnet0` to exist.

## Address Plan

| Host-only network | Kali host address | pfSense address | Purpose |
| :--- | :--- | :--- | :--- |
| `vboxnet0` | `192.168.56.1/24` | `192.168.56.2/24` | HOST_MGMT, trusted access |

Disable the VirtualBox DHCP server on `vboxnet0`; both endpoints use static IP configurations.

## Create Host-only Network

In VirtualBox, open **Tools → Network → Host-only Networks** and create/configure:

1. `vboxnet0`: IPv4 address `192.168.56.1`, mask `255.255.255.0`.
2. Disable DHCP on `vboxnet0`.

Attach pfSense Adapter 7 to `vboxnet0`. In pfSense, assign and enable the corresponding interface as HOST_MGMT (`192.168.56.2/24`). Do not set an upstream gateway on this interface. Verify interface-to-NIC mapping by MAC address; `em6` is an example, not a guarantee. See [VirtualBox provisioning](virtualbox.md) and [interface assignment](interface-assignment.md).

## Trusted Administration Routing

Confirm the host-only interface is up and has its planned address:

```bash
ip -br address
ping -c 3 192.168.56.2
```

Add temporary routes for the lab subnets through pfSense HOST_MGMT:

```bash
sudo ip route replace 10.0.0.0/24 via 192.168.56.2
sudo ip route replace 10.10.10.0/24 via 192.168.56.2
sudo ip route replace 10.20.20.0/24 via 192.168.56.2
sudo ip route replace 10.30.30.0/24 via 192.168.56.2
sudo ip route replace 10.40.40.0/24 via 192.168.56.2
```

Verify the route and gateway reachability:

```bash
ip route get 10.30.30.10
ping -c 3 10.0.0.1
ping -c 3 10.30.30.10
```

These routes are temporary and disappear after reboot. For persistent access, configure routes on the `vboxnet0` NetworkManager profile or add them through your host's network configuration.

## Remote Access: WireGuard Client

For remote administration from a separate Kali system, install/configure the WireGuard client using the peer details from the firewall configuration. Use split-tunnel routes only for authorized destinations:

```ini
AllowedIPs = 10.0.0.0/24, 10.30.30.0/24, 10.50.50.0/24
```

This permits only MGMT, SECURITY, and the tunnel subnet through WireGuard; ordinary Internet traffic stays on the remote network. Do not expose pfSense GUI, SSH, or SIEM ports directly on WAN. See [firewall policies](../configuration/firewall-rules.md) and [NAT/port forwarding](../configuration/nat.md).

## Safety Checks

- Never bridge malware-analysis VMs to the host-only network, NAT, or a physical network.
- Use the access-mode tests in [connectivity validation](../validation/connectivity.md) to verify routing and reachability.
