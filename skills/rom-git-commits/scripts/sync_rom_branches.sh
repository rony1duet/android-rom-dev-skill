#!/usr/bin/env bash
# ==============================================================================
# Script: sync_rom_branches.sh
# Purpose: Fast-forward merges the current branch into a target paired branch
#          and pushes both to origin, keeping ROM trees in parity.
# Usage: ./sync_rom_branches.sh [target_branch]
# Example: ./sync_rom_branches.sh PixelOS-16-QPR2
# ==============================================================================
set -euo pipefail

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TARGET_BRANCH="${1:-PixelOS-16-QPR2}"

if [ "$CURRENT_BRANCH" == "$TARGET_BRANCH" ]; then
    echo "[ERROR] Current branch is already '$TARGET_BRANCH'. Specify a different target."
    exit 1
fi

echo "=== Syncing '${CURRENT_BRANCH}' -> '${TARGET_BRANCH}' ==="

echo "[1/4] Pushing current branch '${CURRENT_BRANCH}' to origin..."
git push origin "${CURRENT_BRANCH}"

echo "[2/4] Switching to target branch '${TARGET_BRANCH}'..."
git checkout "${TARGET_BRANCH}"

echo "[3/4] Merging '${CURRENT_BRANCH}' into '${TARGET_BRANCH}'..."
git merge "${CURRENT_BRANCH}"

echo "[4/4] Pushing '${TARGET_BRANCH}' to origin..."
git push origin "${TARGET_BRANCH}"

echo "Returning to working branch '${CURRENT_BRANCH}'..."
git checkout "${CURRENT_BRANCH}"

echo "✅ Parity synchronization complete!"

