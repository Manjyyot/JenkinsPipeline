#!/bin/bash
set -e

echo "[*] Installing Git..."
sudo apt update
sudo apt install -y git

echo "[*] Cloning Terraform repo..."
cd ~
git clone https://github.com/rajivsharma92/terraform-caps-project.git

echo "[✓] Repository cloned"
