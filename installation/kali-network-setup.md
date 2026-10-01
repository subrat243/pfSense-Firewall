# Kali Host Network Setup

## Purpose

Kali is the physical VirtualBox host, not a lab VM. Its two host-only connections provide distinct access modes through pfSense:

- **HOST_MGMT** is the trusted administration path to the five lab segments.
- **BLACKBOX** is the external-attacker simulation path. It may reach CYBER only; pfSense blocks the other protected networks.

Do not connect Kali directly to any `intnet-*` lab network. Create the host-only networks before provisioning pfSense; the script expects `vboxnet0` and `vboxnet1` to exist.

## Address Plan

| Host-only network | Kali host address | pfSense address | Purpose |
| :--- | :--- | :--- | :--- |
| `vboxnet0` | `192.168.56.1/24` | `192.168.56.2/24` | HOST_MGMT, trusted access |
| `vboxnet1` | `192.168.100.10/24` | `192.168.100.1/24` | BLACKBOX, attacker simulation |

Disable the VirtualBox DHCP server on both host-only networks; these endpoints use static addresses. The host-side address on `vboxnet1` must be `.10`, not `.1`, because `.1` belongs to pfSense. This avoids assigning the same IP to two devices.

## Create Host-only Networks

In VirtualBox, open **Tools → Network → Host-only Networks** and create/configure:

1. `vboxnet0`: IPv4 address `192.168.56.1`, mask `255.255.255.0`.
2. `vboxnet1`: IPv4 address `192.168.100.10`, mask `255.255.255.0`.
3. Disable DHCP on both networks.

Attach pfSense Adapter 7 to `vboxnet0` and Adapter 8 to `vboxnet1`. In pfSense, assign and enable the corresponding interfaces as HOST_MGMT (`192.168.56.2/24`) and BLACKBOX (`192.168.100.1/24`). Do not set an upstream gateway on either interface. Verify interface-to-NIC mapping by MAC address; `em6` and `em7` are examples, not guarantees. See [VirtualBox provisioning](virtualbox.md) and [interface assignment](interface-assignment.md).

## Mode A: Trusted Administration

Confirm the host-only interfaces are up and have their planned addresses:

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

These routes are temporary and disappear after reboot. For persistent access, configure routes on the `vboxnet0` NetworkManager profile or add them through your host's network configuration. Keep this trusted profile disconnected during black-box testing.

## Mode B: Black-box Testing

First disconnect the trusted host-only profile and remove its lab routes. If routes were added temporarily as above:

```bash
sudo ip route del 10.0.0.0/24 via 192.168.56.2
sudo ip route del 10.10.10.0/24 via 192.168.56.2
sudo ip route del 10.20.20.0/24 via 192.168.56.2
sudo ip route del 10.30.30.0/24 via 192.168.56.2
sudo ip route del 10.40.40.0/24 via 192.168.56.2
```

Ensure Kali uses `192.168.100.10/24` on `vboxnet1` and can reach pfSense:

```bash
ping -c 3 192.168.100.1
```

Route probes for all lab subnets through BLACKBOX. These are attacker-side routes through the untrusted interface, not trusted HOST_MGMT routes; they are necessary to ensure protected-subnet scans traverse pfSense and hit its deny rules rather than escaping through Kali's normal default route.

```bash
sudo ip route replace 10.0.0.0/24 via 192.168.100.1
sudo ip route replace 10.10.10.0/24 via 192.168.100.1
sudo ip route replace 10.20.20.0/24 via 192.168.100.1
sudo ip route replace 10.30.30.0/24 via 192.168.100.1
sudo ip route replace 10.40.40.0/24 via 192.168.100.1
```

Confirm the CYBER route uses BLACKBOX, then test the exposed and protected subnets:

```bash
ip route get 10.10.10.10
nmap -Pn 10.10.10.0/24
nmap -Pn 10.0.0.0/24
nmap -Pn 10.20.20.0/24
nmap -Pn 10.30.30.0/24
nmap -Pn 10.40.40.0/24
```

CYBER targets should be reachable; MGMT, AD, SECURITY, and MALWARE should not. Ensure HOST_MGMT is disconnected and its trusted routes are absent before interpreting results. BLACKBOX firewall rules must block protected destinations before allowing CYBER.

## Mode C: WireGuard Client

For remote administration from a separate Kali system, install/configure the WireGuard client using the peer details from the firewall configuration. Use split-tunnel routes only for authorized destinations:

```ini
AllowedIPs = 10.0.0.0/24, 10.30.30.0/24, 10.50.50.0/24
```

This permits only MGMT, SECURITY, and the tunnel subnet through WireGuard; ordinary Internet traffic stays on the remote network. Do not expose pfSense GUI, SSH, or SIEM ports directly on WAN. See [firewall policies](../configuration/firewall-rules.md) and [NAT/port forwarding](../configuration/nat.md).

## Safety Checks

- Never bridge malware-analysis VMs to either host-only network, NAT, or a physical network.
- Do not leave HOST_MGMT active while simulating an external attacker.
- Keep the BLACKBOX host address at `192.168.100.10`; reserve `192.168.100.1` for pfSense.
- Use the access-mode tests in [connectivity validation](../validation/connectivity.md) after each mode change.
