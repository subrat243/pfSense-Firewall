# pfSense OS Installation Walkthrough

## Overview

This document guides you step-by-step through installing **pfSense CE 2.7.2** from ISO image onto the provisioned VirtualBox virtual machine.

---

## Step-by-Step Installation Procedure

### Step 1: Booting the ISO
1. Start the `pfSense-Firewall` VM in VirtualBox.
2. The pfSense installer splash screen will display. Press `Enter` or wait 10 seconds for autoboot.
3. Accept the **Copyright and Distribution Notice** by selecting `<Accept>`.

---

### Step 2: Installer Options
1. On the main installer menu select:
   * **`Install`**: (Install pfSense) and press `Enter`.
2. **Keymap Selection**: Keep default (`Test and continue with default keymap`).
3. **Partitioning**:
   * Select **`Auto (ZFS)`** or **`Auto (UFS) BIOS`** (UFS is lightweight and recommended for 1024 MB RAM).
   * Choose **`Entire Disk`** and confirm partition layout.
   * Confirm writing changes to disk by selecting `<Yes>`.

---

### Step 3: Installation & Reboot
1. The installer will extract base distribution tarballs (`base.txz`, `kernel.txz`).
2. Upon completion, select `<No>` when prompted to open a shell for manual modification.
3. Select `<Reboot>`.
4. Immediately unmount the ISO from VirtualBox Optical Drive (`vboxmanage storageattach "pfSense-Firewall" --storagectl "IDE Controller" --port 0 --device 0 --medium none`) to prevent booting back into the installer.

---

## Console Initial Configuration Screen

Once booted into pfSense OS, the text-based console menu displays:

```text
*** Welcome to pfSense 2.7.2-RELEASE (amd64) ***

  WAN (wan)       -> em0        -> v4/DHCP: 10.0.2.15/24
  LAN (lan)       -> em1        -> v4: 192.168.1.1/24

 0) Logout (SSH only)                  9) pfTop
 1) Assign Interfaces                 10) Filter Logs
 2) Set interface(s) IP address       11) Restart webConfigurator
 3) Reset webConfigurator password    12) PHP shell + pfSense tools
 4) Reset to factory defaults         13) Update from console
 5) Reboot system                     14) Enable Secure Shell (SSH)
 6) Halt system                       15) Restore recent configuration
 7) Ping host                         16) Restart PHP-FPM
 8) Shell
```

---

## Verification & Post-Install Checklist

- [x] pfSense boots cleanly without FreeBSD kernel panic.
- [x] Console menu `0-16` appears successfully.
- [x] Optical ISO drive detached.
- [x] Ready for interface assignment.
