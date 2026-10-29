#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-/tmp}"
PLUGIN_DIR="reader-theme.koplugin"

WORK_DIR=$(mktemp -d)
trap "rm -rf '$WORK_DIR'" EXIT

mkdir -p "$WORK_DIR/$PLUGIN_DIR"
cp -r "$SCRIPT_DIR/book" "$SCRIPT_DIR/lib" "$SCRIPT_DIR/widgets" "$WORK_DIR/$PLUGIN_DIR/"
cp "$SCRIPT_DIR/LICENSE" "$SCRIPT_DIR/README.md" "$SCRIPT_DIR/main.lua" "$SCRIPT_DIR/_meta.lua" "$WORK_DIR/$PLUGIN_DIR/"

cd "$WORK_DIR"
zip -r "$OUTPUT_DIR/$PLUGIN_DIR.zip" "$PLUGIN_DIR"

ls -lh "$OUTPUT_DIR/$PLUGIN_DIR.zip"
