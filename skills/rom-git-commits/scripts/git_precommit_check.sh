#!/usr/bin/env bash
# ==============================================================================
# Script: git_precommit_check.sh
# Purpose: Pre-commit sanity check to prevent accidental staging of IDE caches,
#          build artifacts, test manifests, and CRLF / whitespace errors.
# Usage: ./git_precommit_check.sh [repo_directory]
# ==============================================================================
set -euo pipefail

REPO_DIR="${1:-.}"
cd "${REPO_DIR}"

echo "=== Running Pre-Commit Staging Audit ==="

# 1. Check for forbidden directories
FORBIDDEN_DIRS=(".gradle" ".idea" ".kotlin" "build" ".cxx")
FOUND_FORBIDDEN=0

for dir in "${FORBIDDEN_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "[WARNING] Found forbidden build/IDE directory: '$dir'"
        FOUND_FORBIDDEN=1
    fi
done

# 2. Check for staged forbidden files
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)

if [ -n "$STAGED_FILES" ]; then
    echo "$STAGED_FILES" | while IFS= read -r file; do
        case "$file" in
            *.apk|*.aab|*.iml|*local.properties|*AndroidManifest_debug.xml)
                echo "[ERROR] Staged forbidden file: '$file'"
                FOUND_FORBIDDEN=1
                ;;
        esac
    done
fi

# 3. Check for whitespace or CRLF errors in staged changes
echo "Checking staged changes for whitespace/CRLF errors..."
if ! git diff --cached --check; then
    echo "[ERROR] Staged files contain CRLF or trailing whitespace errors!"
    FOUND_FORBIDDEN=1
fi

if [ "$FOUND_FORBIDDEN" -eq 1 ]; then
    echo "[FAIL] Pre-commit audit failed. Clean your staging area before committing."
    exit 1
fi

echo "[OK] Pre-commit audit passed. Staging area is clean and ready to commit."
