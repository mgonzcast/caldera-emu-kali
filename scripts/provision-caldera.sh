#!/bin/bash

# Caldera Provisioning Script for Kali Linux

set -e

echo "[+] Updating system and installing dependencies..."
sudo apt-get update
sudo apt-get install -y git python3-pip python3-venv golang-go nodejs npm zlib1g-dev 

# Define installation directory
INSTALL_DIR="$HOME/caldera"

if [ -d "$INSTALL_DIR" ]; then
    echo "[!] Installation directory already exists. Please remove or backup $INSTALL_DIR before running."
    exit 1
fi

echo "[+] Cloning Caldera (recursive)..."
git clone https://github.com/mitre/caldera.git --recursive "$INSTALL_DIR"

echo "[+] Setting up Python Virtual Environment..."
python3 -m venv PyEnv
source PyEnv/bin/activate

cd "$INSTALL_DIR"

echo "[+] Installing Python requirements..."
pip3 install --upgrade pip
pip3 install -r requirements.txt


echo "========================================================="
echo "[+] Installation Finished!"
echo "[+] To start Caldera, run the following commands:"
echo "    python3 -m venv PyEnv"
echo "    source PyEnv/bin/activate"
echo "    cd $INSTALL_DIR"
echo "    python3 server.py --insecure"
echo "[+] Access the UI at http://localhost:8888 (red/admin)"
echo "========================================================="
