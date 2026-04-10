#!/bin/bash

# Configuring Emu plugin in Caldera activation and payload download

set -e

echo "[+] Setting up Python Virtual Environment..."
python3 -m venv PyEnv
source PyEnv/bin/activate

# Define installation directory
INSTALL_DIR="$HOME/caldera"

if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR"
fi

# The 'emu' plugin usually requires additional python libraries for decryption
if [ -f "plugins/emu/requirements.txt" ]; then
    echo "[+] Installing Emu plugin requirements..."
    pip3 install -r plugins/emu/requirements.txt
fi

echo "[+] Enabling the Emu plugin in configuration..."
# Use sed to add 'emu' to the plugin list if not already there
if ! grep -i "emu" conf/default.yml; then
    # This inserts '- emu' after the plugins: header
    sed -i '/plugins:/a \- emu' conf/default.yml
    echo "[+] Emu plugin enabled in conf/default.yml"
fi

echo "[+] Initializing Caldera to sync Emu data..."
# We run the server briefly to let Emu clone its internal data repositories, then kill it
# Using --build for the first time as required for the VueJS UI
timeout 60s python3 server.py --insecure --build || echo "[*] Initial sync complete."

echo "[+] Downloading Emu payloads..."
if [ -f "plugins/emu/download_payloads.sh" ]; then
    cd plugins/emu
    # Making sure it's executable
    chmod +x download_payloads.sh
    ./download_payloads.sh
    cd "$INSTALL_DIR"
else
    echo "[-] Warning: download_payloads.sh not found in plugins/emu."
fi

# As mentioned here https://github.com/mitre/emu/issues/44, you need to run this after running download_payloads.sh

python3 ./plugins/emu/data/adversary-emulation-plans/sandworm/Resources/utilities/crypt_executables.py -i ./ -p malware --decrypt

echo "========================================================="
echo "[+] EMU plugin configuration Finished!"
echo "[+] To start Caldera, run the following commands:"
echo "    python3 -m venv PyEnv"
echo "    source PyEnv/bin/activate"
echo "    cd $INSTALL_DIR"
echo "    python3 server.py --insecure"
echo "[+] Access the UI at http://localhost:8888 (red/admin)"
echo "========================================================="
