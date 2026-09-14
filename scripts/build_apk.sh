#!/usr/bin/env bash
# ==============================================================================
# DFM Korba — All-in-One Automated APK Build Script
# Checks prerequisites, sets up Flutter & builds app-release.apk
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=================================================="
echo "      DFM KORBA — AUTOMATED APK GENERATOR         "
echo "=================================================="

# 1. Check Git
if ! command -v git &> /dev/null; then
    echo "[ERROR] 'git' is not installed."
    echo "Please run: sudo apt install -y git"
    exit 1
fi

# 2. Check Java / JDK
if ! command -v java &> /dev/null; then
    echo "[ERROR] Java JDK is not installed."
    echo "Please run: sudo apt install -y openjdk-17-jdk"
    exit 1
fi

# 3. Check or setup Flutter
export PATH="$HOME/flutter/bin:$PATH"
if ! command -v flutter &> /dev/null; then
    echo "[INFO] Flutter SDK not found in PATH or ~/flutter."
    echo "[INFO] Running setup_flutter.sh..."
    bash "${SCRIPT_DIR}/setup_flutter.sh"
    export PATH="$HOME/flutter/bin:$PATH"
fi

echo "[OK] Flutter version:"
flutter --version

cd "${PROJECT_DIR}"

# 4. Resolve dependencies
echo ""
echo "[INFO] Fetching Flutter dependencies..."
flutter pub get

# 5. Build Release APK
echo ""
echo "[INFO] Compiling Android Release APK..."
flutter build apk --release

APK_OUTPUT="${PROJECT_DIR}/build/app/outputs/flutter-apk/app-release.apk"

if [ -f "${APK_OUTPUT}" ]; then
    echo ""
    echo "=================================================="
    echo " [SUCCESS] APK BUILD COMPLETE!"
    echo " Location: ${APK_OUTPUT}"
    echo " File Size: $(du -h "${APK_OUTPUT}" | cut -f1)"
    echo "=================================================="
else
    echo "[ERROR] APK file not found at expected path."
    exit 1
fi
