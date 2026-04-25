#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY_NAME="cosmic-comp"
INSTALLED_PATH="/usr/bin/${BINARY_NAME}"
BUILT_PATH="${REPO_DIR}/target/release/${BINARY_NAME}"

echo "=== Building cosmic-comp (release) ==="
cd "$REPO_DIR"
cargo build --release

if [ ! -f "$BUILT_PATH" ]; then
    echo "ERROR: Build succeeded but binary not found at ${BUILT_PATH}"
    exit 1
fi

echo "=== Build complete ==="
echo "Built binary: ${BUILT_PATH}"

# Check the installed binary exists
if [ ! -f "$INSTALLED_PATH" ]; then
    echo "ERROR: No existing binary found at ${INSTALLED_PATH}"
    exit 1
fi

# Backup the current binary
echo "=== Backing up current binary ==="
if [ -f "${INSTALLED_PATH}-BU" ]; then
    echo "WARNING: Backup already exists at ${INSTALLED_PATH}-BU"
    read -p "Overwrite existing backup? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Aborted."
        exit 1
    fi
fi

sudo mv "$INSTALLED_PATH" "${INSTALLED_PATH}-BU"
echo "Backed up: ${INSTALLED_PATH} -> ${INSTALLED_PATH}-BU"

# Copy new binary into place
echo "=== Installing new binary ==="
sudo cp "$BUILT_PATH" "$INSTALLED_PATH"
sudo chmod 755 "$INSTALLED_PATH"
echo "Installed: ${BUILT_PATH} -> ${INSTALLED_PATH}"

echo ""
echo "=== Done ==="
echo "New binary:    ${INSTALLED_PATH}"
echo "Backup:        ${INSTALLED_PATH}-BU"
echo ""
echo "To restore the original: sudo mv ${INSTALLED_PATH}-BU ${INSTALLED_PATH}"
