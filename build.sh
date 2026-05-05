#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="ThaiDictate"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS}/MacOS"

echo "[1/4] Cleaning previous build..."
rm -rf "${APP_BUNDLE}"

echo "[2/5] Creating app bundle structure..."
RESOURCES_DIR="${CONTENTS}/Resources"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"
cp Info.plist "${CONTENTS}/Info.plist"

echo "[3/5] Generating icon (if needed)..."
if [ ! -f "AppIcon.icns" ] || [ "generate_icon.swift" -nt "AppIcon.icns" ]; then
  swift generate_icon.swift
  iconutil -c icns AppIcon.iconset -o AppIcon.icns
fi
cp AppIcon.icns "${RESOURCES_DIR}/AppIcon.icns"

echo "[4/5] Compiling Swift..."
swiftc -O \
  -o "${MACOS_DIR}/${APP_NAME}" \
  main.swift \
  -framework Cocoa \
  -framework Speech \
  -framework AVFoundation

echo "[5/5] Ad-hoc signing..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo ""
echo "✅ Build complete: ${APP_BUNDLE}"
echo ""
echo "Run with:"
echo "  open ${APP_BUNDLE}"
