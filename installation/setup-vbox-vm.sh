#!/usr/bin/env bash
# ==============================================================================
# Enterprise pfSense VirtualBox Provisioning Script
# ==============================================================================
# Automates VM creation, 20GB VDI disk allocation, and 6 Network Adapters assignment.
#
# Usage:
#   chmod +x installation/setup-vbox-vm.sh
#   ./installation/setup-vbox-vm.sh [VM_NAME] [ISO_PATH]
# ==============================================================================

set -euo pipefail

VM_NAME="${1:-pfSense}"
ISO_PATH="${2:-${HOME}/Downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso}"
VM_DIR="${HOME}/VirtualBox VMs/${VM_NAME}"
DISK_PATH="${VM_DIR}/${VM_NAME}.vdi"

echo "========================================================================"
echo "          Provisioning pfSense Virtual Firewall on VirtualBox          "
echo "========================================================================"
echo "[*] VM Name     : ${VM_NAME}"
echo "[*] RAM / vCPU  : 1024 MB / 2 vCPUs"
echo "[*] Storage Disk: 20 GB VDI dynamically allocated"
echo "[*] ISO Path    : ${ISO_PATH}"
echo "------------------------------------------------------------------------"

# 1. Register Virtual Machine if not existing
if VBoxManage showvminfo "${VM_NAME}" &>/dev/null; then
    echo "[!] VM '${VM_NAME}' already exists in VirtualBox."
else
    echo "[*] Creating Virtual Machine: ${VM_NAME}"
    VBoxManage createvm --name "${VM_NAME}" --ostype "FreeBSD_64" --register
fi

# 2. Modify Hardware Resources
echo "[*] Setting RAM (1024 MB), vCPUs (2), and boot priority..."
VBoxManage modifyvm "${VM_NAME}" \
    --cpus 2 \
    --memory 1024 \
    --vram 16 \
    --boot1 dvd \
    --boot2 disk \
    --rtcuseutc on

# 3. Storage Setup
mkdir -p "${VM_DIR}"

if [ ! -f "${DISK_PATH}" ]; then
    echo "[*] Creating 20 GB VDI hard disk..."
    VBoxManage createmedium disk --filename "${DISK_PATH}" --size 20480 --format VDI
fi

if ! VBoxManage showvminfo "${VM_NAME}" | grep -q "SATA Controller"; then
    echo "[*] Attaching SATA Controller and VDI Medium..."
    VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAhci
    VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${DISK_PATH}"
fi

if ! VBoxManage showvminfo "${VM_NAME}" | grep -q "IDE Controller"; then
    echo "[*] Attaching IDE Controller..."
    VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" --add ide
fi

if [ -f "${ISO_PATH}" ]; then
    echo "[*] Mounting pfSense ISO: ${ISO_PATH}"
    VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${ISO_PATH}"
else
    echo "[!] Warning: ISO file not found at ${ISO_PATH}."
    echo "    Mount ISO manually before starting VM."
fi

# 4. Configure 6 Network Adapters
echo "[*] Configuring 6 Network Adapters..."

# Adapter 1 - WAN (NAT)
VBoxManage modifyvm "${VM_NAME}" --nic1 nat
VBoxManage modifyvm "${VM_NAME}" --nictype1 82545EM

# Adapter 2 - Management (intnet-mgmt)
VBoxManage modifyvm "${VM_NAME}" --nic2 intnet
VBoxManage modifyvm "${VM_NAME}" --intnet2 "intnet-mgmt"
VBoxManage modifyvm "${VM_NAME}" --nictype2 82545EM

# Adapter 3 - Cyber Range (intnet-cyber)
VBoxManage modifyvm "${VM_NAME}" --nic3 intnet
VBoxManage modifyvm "${VM_NAME}" --intnet3 "intnet-cyber"
VBoxManage modifyvm "${VM_NAME}" --nictype3 82545EM

# Adapter 4 - Active Directory (intnet-ad)
VBoxManage modifyvm "${VM_NAME}" --nic4 intnet
VBoxManage modifyvm "${VM_NAME}" --intnet4 "intnet-ad"
VBoxManage modifyvm "${VM_NAME}" --nictype4 82545EM

# Adapter 5 - Security Monitoring (intnet-sec)
VBoxManage modifyvm "${VM_NAME}" --nic5 intnet
VBoxManage modifyvm "${VM_NAME}" --intnet5 "intnet-sec"
VBoxManage modifyvm "${VM_NAME}" --nictype5 82545EM

# Adapter 6 - Malware Analysis (intnet-malware)
VBoxManage modifyvm "${VM_NAME}" --nic6 intnet
VBoxManage modifyvm "${VM_NAME}" --intnet6 "intnet-malware"
VBoxManage modifyvm "${VM_NAME}" --nictype6 82545EM

echo "------------------------------------------------------------------------"
echo "[+] pfSense VM '${VM_NAME}' successfully configured!"
echo "========================================================================"
echo "[*] Verifying Network Adapters Attachment:"
VBoxManage showvminfo "${VM_NAME}" | grep "NIC"
