#!/usr/bin/env bash
# ==============================================================================
# DFM Korba Android Release Keystore Generator
# Generates a production-grade RSA 2048-bit keystore for Google Play signing.
# ==============================================================================

set -euo pipefail

KEYSTORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../android/app" && pwd)"
KEYSTORE_PATH="${KEYSTORE_DIR}/dfm-upload-keystore.jks"
KEY_ALIAS="dfmupload"

echo "=================================================="
echo "DFM KORBA — PRODUCTION KEYSTORE GENERATOR"
echo "Target path: ${KEYSTORE_PATH}"
echo "=================================================="

if [ -f "${KEYSTORE_PATH}" ]; then
    echo "WARNING: Keystore already exists at ${KEYSTORE_PATH}"
    read -p "Do you wish to overwrite it? [y/N]: " confirm
    if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

keytool -genkey -v \
    -keystore "${KEYSTORE_PATH}" \
    -storetype JKS \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "${KEY_ALIAS}"

echo ""
echo "=================================================="
echo "Keystore created successfully!"
echo "Now create android/key.properties with the following contents:"
echo ""
echo "storePassword=<YOUR_STORE_PASSWORD>"
echo "keyPassword=<YOUR_KEY_PASSWORD>"
echo "keyAlias=${KEY_ALIAS}"
echo "storeFile=dfm-upload-keystore.jks"
echo "=================================================="
