#!/bin/bash

# Define paths

TARGET_DIR="/home/kali/caldera/plugins/emu/data/adversary-emulation-plans/oilrig/Emulation_Plan/yaml"
TARGET_FILE="${TARGET_DIR}/oilrig.yaml"

# Raw URL for the updated oilrig.yaml from PR #47 (branch: oilrig-update)
RAW_YAML_URL="https://raw.githubusercontent.com/mgonzcast/ael/refs/heads/patch-3/ManagedServices/oilrig/Emulation_Plan/yaml/oilrig.yaml"

echo "=== Starting Caldera OilRig Emulation Plan Update ==="

# Ensure the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating target directory path..."
    mkdir -p "$TARGET_DIR"
fi

# Backup the original file if it exists and hasn't been backed up yet
if [ -f "$TARGET_FILE" ]; then
    if [ ! -f "${TARGET_FILE}.bak" ]; then
        echo "Backing up original oilrig.yaml to oilrig.yaml.bak..."
        cp "$TARGET_FILE" "${TARGET_FILE}.bak"
    else
        echo "Backup file already exists. Skipping backup step."
    fi
fi

# Download the updated YAML file from the PR branch
echo "Downloading updated oilrig.yaml from PR #47..."
if curl -s -f -o "$TARGET_FILE" "$RAW_YAML_URL"; then
    echo "Successfully replaced oilrig.yaml!"
else
    echo "Error: Failed to download the file from GitHub. Please check your internet connection." >&2
    exit 1
fi

echo "=== OilRig Emulation Plan Update Complete ==="