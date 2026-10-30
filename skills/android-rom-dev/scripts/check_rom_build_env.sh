#!/usr/bin/env bash
# ==============================================================================
# Script: check_rom_build_env.sh
# Purpose: Inspects build container/machine memory, swap, disk space, and
#          prebuilt toolchain ELF binaries to prevent early build abortions.
# Usage: ./check_rom_build_env.sh
# ==============================================================================
set -euo pipefail

echo "=================================================="
echo "Checking Android Build Environment Readiness"
echo "=================================================="

# 1. Memory and Swap inspection
echo "[1/4] Checking RAM and Swap space..."
free -h 2>/dev/null || true
TOTAL_SWAP_MB=$(free -m 2>/dev/null | awk '/^Swap:/ {print $2}' || echo "0")
if [ -n "$TOTAL_SWAP_MB" ] && [ "$TOTAL_SWAP_MB" -lt 8192 ]; then
    echo "WARNING: Swap is below 8GB (${TOTAL_SWAP_MB}MB). Creating 16GB swap..."
    if command -v sudo >/dev/null 2>&1; then
        sudo fallocate -l 16G /swapfile 2>/dev/null || sudo dd if=/dev/zero of=/swapfile bs=1M count=16384 2>/dev/null || true
        sudo chmod 600 /swapfile 2>/dev/null || true
        sudo mkswap /swapfile 2>/dev/null || true
        sudo swapon /swapfile 2>/dev/null || true
        echo "Swap updated:"
        free -h 2>/dev/null || true
    else
        echo "Notice: sudo not available, cannot auto-provision swapfile."
    fi
else
    echo "Swap space is sufficient."
fi

# 2. Disk Space inspection
echo "[2/4] Checking storage space..."
df -h . /tmp 2>/dev/null || true

# 3. Toolchain & Git LFS Verification
echo "[3/4] Verifying prebuilt compiler binaries (Git LFS check)..."
CLANG_BIN=$(find prebuilts/clang/host/linux-x86 -maxdepth 3 -type f -name clang 2>/dev/null | head -n 1 || true)
if [ -n "$CLANG_BIN" ]; then
    FILE_TYPE=$(file "$CLANG_BIN" || true)
    if echo "$FILE_TYPE" | grep -q "ELF 64-bit"; then
        echo "Clang binary is valid ELF executable: $CLANG_BIN"
    else
        echo "ERROR: Clang binary is NOT an ELF executable! (Likely Git LFS pointer text file)"
        echo "Run: git -C prebuilts/clang/host/linux-x86 lfs pull"
    fi
else
    echo "Notice: No prebuilt clang found in current directory tree."
fi

# 4. Export optimal GC and Soong parameters
echo "[4/4] Setting recommended build environment flags..."
export GOGC=40
export GOMEMLIMIT=14GiB
export MALLOC_ARENA_MAX=2
export SOONG_GOGC=40
export SOONG_INCREMENTAL_ANALYSIS=false

echo "=================================================="
echo "Environment check complete!"
echo "=================================================="

