#!/usr/bin/env bash
# ==============================================================================
# Script: sanitize_line_endings.sh
# Purpose: Normalizes CRLF (\r\n) line endings to UNIX LF (\n) across all
#          critical Android build files and verifies .gitattributes.
# Usage: ./sanitize_line_endings.sh [target_directory]
# ==============================================================================
set -euo pipefail

TARGET_DIR="${1:-.}"

echo "=== Normalizing line endings to UNIX LF in: ${TARGET_DIR} ==="

find "${TARGET_DIR}" -type f \( \
    -name "*.sh" -o \
    -name "*.env" -o \
    -name "*.mk" -o \
    -name "*.bp" -o \
    -name "*.xml" -o \
    -name "*.rc" -o \
    -name "*.te" -o \
    -name "*.cil" -o \
    -name "*.prop" -o \
    -name "*.md" \
\) -not -path "*/.git/*" -not -path "*/out/*" -exec sed -i 's/\r$//' {} + 2>/dev/null || true

echo "=== Ensuring .gitattributes enforce eol=lf ==="
if [ -f "${TARGET_DIR}/.gitattributes" ]; then
    if ! grep -q "eol=lf" "${TARGET_DIR}/.gitattributes"; then
        echo "* text=auto eol=lf" >> "${TARGET_DIR}/.gitattributes"
    fi
fi

echo "Done! All target files converted to UNIX LF."

