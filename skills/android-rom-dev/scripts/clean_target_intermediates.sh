#!/usr/bin/env bash
#
# Cleans conflicting intermediates and unneeded test artifacts without wiping out/
#
set -euo pipefail

DEVICE="${1:-sweet2}"
echo "==> Cleaning intermediate targets for ${DEVICE}..."

rm -rf \
    "out/target/product/${DEVICE}/symbols" \
    "out/target/product/${DEVICE}/data" \
    "out/target/product/${DEVICE}/testcases" \
    "out/host/linux-x86/testcases" \
    "out/dist" \
    "out/soong/.intermediates/art" \
    "out/soong/.intermediates/bionic" \
    "out/target/product/${DEVICE}/obj/KERNEL_OBJ" \
    "out/target/product/${DEVICE}/obj/PACKAGING" \
    "out/target/product/${DEVICE}/etc/vintf" \
    "out/target/product/${DEVICE}/system/etc/vintf" \
    "out/soong/.intermediates/system/sepolicy/recovery_sepolicy.*" \
    "out/soong/.intermediates/vendor/GCam_${DEVICE}" \
    "out/target/product/${DEVICE}/product/app/GoogleCameraEng" 2>/dev/null || true

# Prune Git LFS local cache
find . -type d -name "objects" -path "*/.git/lfs/objects" -exec rm -rf {} + 2>/dev/null || true

echo "Done. Stale targets cleared for fast incremental build."
