#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN="/Applications/Godot 2.app/Contents/MacOS/Godot"
PROJECT_DIR="/Users/normanmahendra/Documents/CardThrone"

mkdir -p "$PROJECT_DIR/builds/web" "$PROJECT_DIR/builds/macos" "$PROJECT_DIR/builds/windows" "$PROJECT_DIR/builds/linux"

echo "=== Exporting Web ==="
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release "Web" "$PROJECT_DIR/builds/web/index.html"

echo "=== Exporting macOS ==="
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release "macOS" "$PROJECT_DIR/builds/macos/PawAndPrism.zip"

echo "=== Exporting Windows Desktop ==="
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release "Windows Desktop" "$PROJECT_DIR/builds/windows/PawAndPrism.exe"

echo "=== Exporting Linux ==="
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release "Linux" "$PROJECT_DIR/builds/linux/PawAndPrism.x86_64"

echo "=== Build Summary ==="
ls -lh "$PROJECT_DIR/builds/web" "$PROJECT_DIR/builds/macos" "$PROJECT_DIR/builds/windows" "$PROJECT_DIR/builds/linux"
