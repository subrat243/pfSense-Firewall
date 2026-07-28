# VirtualBox VM Provisioning & Hardware Setup

## Overview

This guide details the creation and configuration of the **pfSense Virtual Machine** on Oracle VM VirtualBox. pfSense acts as a virtual multi-interface router requiring 6 distinct network adapters.

---

## VM Hardware Allocation

| Parameter | Recommended Value | Minimum Value | Rationale |
| :--- | :--- | :--- | :--- |
| **VM Name** | `pfSense-Firewall` | - | Standard naming scheme |
| **OS Type** | FreeBSD (64-bit) | FreeBSD (64-bit) | pfSense base kernel architecture |
| **Base RAM** | `1024 MB` (1 GB) | `512 MB` | Sufficient for packet routing, DNS, & state tracking |
| **Processors** | `2 vCPU` | `1 vCPU` | Smooth packet processing and WebGUI responsiveness |
| **Storage Disk** | `20 GB` (VDI, Dynamically Allocated) | `8 GB` | Stores FreeBSD OS, logs, and state databases |
| **Storage Controller** | AHCI (SATA) / IDE | - | Standard virtual drive bus |

---

## Virtual Network Adapter Configuration

pfSense requires 6 total virtual network interface cards (NICs). Because VirtualBox WebGUI defaults to 4 NICs per VM, CLI configuration using `VBoxManage` is required to attach NIC 5 and NIC 6.

### Adapter Mapping Matrix

| Adapter # | Network Mode | Internal Network Name | pfSense OS NIC ID | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Adapter 1** | `NAT` | - | `em0` | WAN Internet Gateway |
| **Adapter 2** | `Internal Network` | `intnet-mgmt` | `em1` | Management Network (`10.0.0.0/24`) |
| **Adapter 3** | `Internal Network` | `intnet-cyber` | `em2` | Cyber Range Network (`10.10.10.0/24`) |
| **Adapter 4** | `Internal Network` | `intnet-ad` | `em3` | Active Directory (`10.20.20.0/24`) |
| **Adapter 5** | `Internal Network` | `intnet-security` | `em4` | Security Operations (`10.30.30.0/24`) |
| **Adapter 6** | `Internal Network` | `intnet-malware` | `em5` | Malware Sandbox (`10.40.40.0/24`) |

---

## Automated Provisioning Script (VBoxManage CLI)

Execute the following commands on the Kali Linux host terminal to create and configure the pfSense VM:

```bash
#!/usr/bin/env bash
set -euo pipefail

VM_NAME="pfSense-Firewall"
ISO_PATH="${HOME}/Downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso"
DISK_PATH="${HOME}/VirtualBox VMs/${VM_NAME}/${VM_NAME}.vdi"

echo "[*] Creating VirtualBox VM: ${VM_NAME}"
vboxmanage createvm --name "${VM_NAME}" --ostype "FreeBSD_64" --register

echo "[*] Setting RAM and vCPU parameters..."
vboxmanage modifyvm "${VM_NAME}" \
    --cpus 2 \
    --memory 1024 \
    --vram 16 \
    --boot1 dvd \
    --boot2 disk \
    --rtcuseutc on

echo "[*] Creating 20GB Storage VDI..."
mkdir -p "${HOME}/VirtualBox VMs/${VM_NAME}"
vboxmanage createmedium disk --filename "${DISK_PATH}" --size 20480 --format VDI

echo "[*] Attaching Storage Controllers..."
vboxmanage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAhci
vboxmanage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${DISK_PATH}"

vboxmanage storagectl "${VM_NAME}" --name "IDE Controller" --add ide
if [ -f "${ISO_PATH}" ]; then
    vboxmanage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${ISO_PATH}"
fi

echo "[*] Configuring 6 Network Adapters..."
# Adapter 1: WAN (NAT)
vboxmanage modifyvm "${VM_NAME}" --nic1 nat --nictype1 82545EM

# Adapter 2: Management (Internal Network)
vboxmanage modifyvm "${VM_NAME}" --nic2 intnet --intnet2 intnet-mgmt --nictype2 82545EM --nicpromisc2 allow-all

# Adapter 3: Cyber Range (Internal Network)
vboxmanage modifyvm "${VM_NAME}" --nic3 intnet --intnet3 intnet-cyber --nictype3 82545EM --nicpromisc3 allow-all

# Adapter 4: Active Directory (Internal Network)
vboxmanage modifyvm "${VM_NAME}" --nic4 intnet --intnet4 intnet-ad --nictype4 82545EM --nicpromisc4 allow-all

# Adapter 5: Security Operations (Internal Network)
vboxmanage modifyvm "${VM_NAME}" --nic5 intnet --intnet5 intnet-security --nictype5 82545EM --nicpromisc5 allow-all

# Adapter 6: Malware Sandbox (Internal Network)
vboxmanage modifyvm "${VM_NAME}" --nic6 intnet --intnet6 intnet-malware --nictype6 82545EM --nicpromisc6 allow-all

echo "[+] VM ${VM_NAME} successfully provisioned!"
```

---

## Verification Command

After provisioning, verify the VM specification by running:

```bash
vboxmanage showvminfo "pfSense-Firewall" | grep -E "NIC|Memory|CPUs"
```
