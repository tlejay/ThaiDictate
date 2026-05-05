#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="ThaiDictate"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS}/MacOS"

echo "[1/4] Cleaning previous build..."
rm -rf "${APP_BUNDLE}"

echo "[2/4] Creating app bundle structure..."
mkdir -p "${MACOS_DIR}"
cp Info.plist "${CONTENTS}/Info.plist"

echo "[3/4] Compiling Swift..."
swiftc -O \
  -o "${MACOS_DIR}/${APP_NAME}" \
  main.swift \
  -framework Cocoa \
  -framework Speech \
  -framework AVFoundation

echo "[4/4] Ad-hoc signing..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo ""
echo "✅ Build complete: ${APP_BUNDLE}"
echo ""
echo "Run with:"
echo "  open ${APP_BUNDLE}"
