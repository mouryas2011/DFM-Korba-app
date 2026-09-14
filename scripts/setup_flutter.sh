#!/usr/bin/env bash
# ==============================================================================
# DFM Korba — Flutter SDK Installer & Environment Setup Helper
# Downloads and sets up Flutter SDK in user space (~/flutter)
# ==============================================================================

set -euo pipefail

FLUTTER_TARGET_DIR="$HOME/flutter"

echo "=================================================="
echo "DFM KORBA — FLUTTER SETUP HELPER"
echo "Target installation: ${FLUTTER_TARGET_DIR}"
echo "=================================================="

if [ -d "${FLUTTER_TARGET_DIR}" ]; then
    echo "Flutter directory already exists at ${FLUTTER_TARGET_DIR}."
else
    echo "Downloading Flutter SDK stable channel archive..."
    mkdir -p "$HOME/flutter_tmp"
    wget -q --show-progress -O "$HOME/flutter_tmp/flutter.tar.xz" \
        https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz
    
    echo "Extracting Flutter SDK to $HOME..."
    tar -xf "$HOME/flutter_tmp/flutter.tar.xz" -C "$HOME"
    rm -rf "$HOME/flutter_tmp"
    echo "Flutter SDK extracted successfully."
fi

# Export PATH
export PATH="$FLUTTER_TARGET_DIR/bin:$PATH"

echo "Checking Flutter version..."
flutter --version

echo ""
echo "To make Flutter permanently available in your shell, add this line to your ~/.bashrc:"
echo 'export PATH="$HOME/flutter/bin:$PATH"'
echo ""
echo "Now you can run inside the project directory:"
echo "flutter pub get"
echo "flutter run"
echo "flutter build apk --release"
echo "flutter build appbundle --release"
