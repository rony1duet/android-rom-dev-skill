#!/usr/bin/env bash
# ==============================================================================
# Script: clean_target_intermediates.sh
# Purpose: Safely removes volatile intermediate build objects without wiping
#          the entire out/ directory, preserving the compiler cache.
# Usage: ./clean_target_intermediates.sh [device_codename]
# ==============================================================================
set -euo pipefail

DEVICE="${1:-sweet2}"

echo "=== Performing surgical intermediate cleanup for device: ${DEVICE} ==="

# 1. Kernel objects
echo "Clearing partial kernel objects..."
rm -rf "out/target/product/${DEVICE}/obj/KERNEL_OBJ" 2>/dev/null || true

# 2. VINTF compatibility check intermediates
echo "Clearing VINTF validation intermediates..."
rm -rf "out/target/product/${DEVICE}/obj/PACKAGING/check_vintf_all_intermediates" 2>/dev/null || true
rm -f "out/target/product/${DEVICE}/vendor/etc/vintf/manifest.xml" 2>/dev/null || true

# 3. SELinux policy intermediate objects
echo "Clearing SELinux policy intermediates..."
rm -rf out/soong/.intermediates/system/sepolicy/recovery_sepolicy.* 2>/dev/null || true
rm -f out/soong/.intermediates/system/sepolicy/tools/version_policy/*/obj/system/sepolicy/tools/version_policy.o 2>/dev/null || true

# 4. Outdated package replacements
echo "Clearing stale debloated package intermediates..."
rm -rf "out/target/product/${DEVICE}/system/app/Stk" "out/target/product/${DEVICE}/system/priv-app/Stk" 2>/dev/null || true
rm -rf "out/target/product/${DEVICE}/system_ext/app/Aperture"* "out/target/product/${DEVICE}/product/app/SafetyHub"* 2>/dev/null || true
rm -rf "out/target/product/${DEVICE}/system/app/FMRadio" "out/target/product/${DEVICE}/system/app/FM2" 2>/dev/null || true

echo "Done! Intermediate objects cleared. Ready for incremental build."

