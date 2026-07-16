#!/bin/bash

# Define download targets and URLs
KALI_VERSION="2026.1"
ISO_NAME="kali-linux-${KALI_VERSION}-installer-amd64.iso"
BASE_URL="https://cdimage.kali.org/kali-${KALI_VERSION}"

# Target folder
TARGET_DIR="isos"
ISO_PATH="${TARGET_DIR}/${ISO_NAME}"

# Artifact links
ISO_URL="${BASE_URL}/${ISO_NAME}"
CHECKSUM_URL="${BASE_URL}/SHA256SUMS"
SIG_URL="${BASE_URL}/SHA256SUMS.gpg"
KEY_URL="https://archive.kali.org/archive-key.asc"

echo "=== Starting Kali Linux ${KALI_VERSION} ISO Download Process ==="

# Ensure the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating directory: $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
fi

# Download SHA256SUMS and its signature for verification
echo "Downloading verification files..."
curl -sSL -o "${TARGET_DIR}/SHA256SUMS" "${CHECKSUM_URL}"
curl -sSL -o "${TARGET_DIR}/SHA256SUMS.gpg" "${SIG_URL}"

# Import Kali's GPG archive key and verify the checksum file
echo "Importing Kali's official GPG archive key..."
curl -sSL "${KEY_URL}" | gpg --import --quiet || true

echo "Verifying the integrity of SHA256SUMS using GPG..."
if gpg --verify "${TARGET_DIR}/SHA256SUMS.gpg" "${TARGET_DIR}/SHA256SUMS" 2>/dev/null; then
    echo "[✓] SHA256SUMS file signature verified successfully!"
else
    echo "[!] Warning: Could not verify GPG signature (perhaps the key isn't trusted yet)."
    echo "    Continuing with SHA256 integrity checks..."
fi

# Download the installer ISO
if [ -f "$ISO_PATH" ]; then
    echo "An existing file named '${ISO_PATH}' was found."
    echo "Attempting to resume download if incomplete..."
    # -C - resumes download if supported by the server
    curl -L -C - -o "$ISO_PATH" "${ISO_URL}"
else
    echo "Downloading ${ISO_NAME} to ${TARGET_DIR} (~4.4 GB)..."
    curl -L -o "$ISO_PATH" "${ISO_URL}"
fi

# Verify the downloaded ISO matches the checksum
echo "Calculating SHA256 checksum (this can take a moment)..."
# Using pushd/popd so sha256sum matches relative paths inside the directory correctly
pushd "$TARGET_DIR" > /dev/null
if sha256sum --ignore-missing -c SHA256SUMS 2>&1 | grep -q "${ISO_NAME}: OK"; then
    popd > /dev/null
    echo "[✓] SUCCESS: Checksum match verified. The ISO is complete and uncorrupted!"
    
    # Cleanup verification files
    rm -f "${TARGET_DIR}/SHA256SUMS" "${TARGET_DIR}/SHA256SUMS.gpg"
else
    popd > /dev/null
    echo "[✗] ERROR: Checksum validation failed! The downloaded file is corrupt or incomplete." >&2
    exit 1
fi

echo "=== Process Complete ==="
