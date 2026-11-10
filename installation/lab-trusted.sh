#!/usr/bin/env bash
# lab-trusted.sh — Laboratory administration via HOST_MGMT
set -euo pipefail

echo "[*] Activating Trusted Laboratory Administration..."
sudo ip link set vboxnet0 up
sudo ip addr replace 192.168.56.1/24 dev vboxnet0

for subnet in 10.0.0.0/24 10.10.10.0/24 10.20.20.0/24 10.30.30.0/24 10.40.40.0/24; do
  sudo ip route replace "${subnet}" via 192.168.56.2 dev vboxnet0
done

echo "[+] Trusted administration routing active via 192.168.56.2:"
ip route | grep -E "10\.|192\.168\."
