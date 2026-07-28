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

## Network Adapter VBoxManage Commands

Based on **Project 01 - Enterprise Firewall**, configure the network adapters on your VM using the following commands (replace `"pfSense"` with `"pfSense-Firewall"` if your VM name includes the suffix):

```bash
# Adapter 1 - WAN (NAT)
VBoxManage modifyvm "pfSense" --nic1 nat
VBoxManage modifyvm "pfSense" --nictype1 82545EM

# Adapter 2 - Management
VBoxManage modifyvm "pfSense" --nic2 intnet
VBoxManage modifyvm "pfSense" --intnet2 "intnet-mgmt"
VBoxManage modifyvm "pfSense" --nictype2 82545EM

# Adapter 3 - Cyber Range
VBoxManage modifyvm "pfSense" --nic3 intnet
VBoxManage modifyvm "pfSense" --intnet3 "intnet-cyber"
VBoxManage modifyvm "pfSense" --nictype3 82545EM

# Adapter 4 - Active Directory
VBoxManage modifyvm "pfSense" --nic4 intnet
VBoxManage modifyvm "pfSense" --intnet4 "intnet-ad"
VBoxManage modifyvm "pfSense" --nictype4 82545EM

# Adapter 5 - Security Monitoring
VBoxManage modifyvm "pfSense" --nic5 intnet
VBoxManage modifyvm "pfSense" --intnet5 "intnet-sec"
VBoxManage modifyvm "pfSense" --nictype5 82545EM

# Adapter 6 - Malware Analysis
VBoxManage modifyvm "pfSense" --nic6 intnet
VBoxManage modifyvm "pfSense" --intnet6 "intnet-malware"
VBoxManage modifyvm "pfSense" --nictype6 82545EM
```

---

## Adapter Configuration Verification

To verify that all 6 network adapters are attached correctly, run:

```bash
VBoxManage showvminfo "pfSense" | grep "NIC"
```

### Expected Verification Output

```text
NIC 1: Attachment: NAT
NIC 2: Attachment: Internal Network 'intnet-mgmt'
NIC 3: Attachment: Internal Network 'intnet-cyber'
NIC 4: Attachment: Internal Network 'intnet-ad'
NIC 5: Attachment: Internal Network 'intnet-sec'
NIC 6: Attachment: Internal Network 'intnet-malware'
```

Once this is complete, proceed to the **[pfSense Installation](pfsense-install.md)** and **[Interface Assignment](interface-assignment.md)**.

