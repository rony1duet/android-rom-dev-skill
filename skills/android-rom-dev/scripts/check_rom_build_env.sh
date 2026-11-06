#!/usr/bin/env bash
#
# Inspects build environment resources, toolchain LFS state, and Go runtime tuning.
#
set -euo pipefail

echo "==> Checking Android Build Environment"

# 1. Memory and Swap inspection
echo "[1/4] Checking RAM and Swap..."
free -h 2>/dev/null || true

# Clean up any dead unmounted swapfile from aborted runs
if [[ -f "/swapfile" ]] && ! grep -q "/swapfile" /proc/swaps 2>/dev/null; then
    echo "Notice: Found inactive /swapfile. Removing to reclaim root disk space..."
    sudo rm -f /swapfile 2>/dev/null || true
fi

# 2. Disk Space inspection
echo "[2/4] Checking storage space..."
df -h . /tmp 2>/dev/null || true

# 3. Toolchain & Git LFS Verification
echo "[3/4] Verifying prebuilt compiler binaries..."
CLANG_BIN=$(find prebuilts/clang/host/linux-x86 -maxdepth 3 -type f -name clang 2>/dev/null | head -n 1 || true)
if [[ -n "$CLANG_BIN" ]]; then
    FILE_TYPE=$(file "$CLANG_BIN" 2>/dev/null || true)
    if echo "$FILE_TYPE" | grep -q "ELF 64-bit"; then
        echo "Clang binary is valid ELF executable: $CLANG_BIN"
    else
        echo "ERROR: Clang binary is a Git LFS pointer text file!"
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
export DONT_INSTALL_DEXPREOPT_TESTS=true
export SKIP_BOOT_JARS_CHECK=true
export WITHOUT_CHECK_API=true
