---
name: android-rom-dev
description: >-
  Expert guide and troubleshooting system for developing, compiling, and debugging
  Android custom ROMs (AOSP, LineageOS, PixelOS, CrDroid, etc.), device trees, vendor packages,
  hardware HALs, kernel trees, Soong/Kati build systems, and prebuilts.
  Use this skill whenever diagnosing Android ROM build failures, writing or fixing Android.bp / Android.mk /
  device.mk makefiles, managing memory/swap in build containers, fixing CRLF/bash/curl errors,
  or resolving SEPolicy, VINTF, and AudioFX integration issues.
---

# Android Custom ROM Development & Troubleshooting Guide

Comprehensive engineering reference for building and debugging Android custom ROMs (Android 14, 15, 16, 17+).

## Failure Diagnostic Flow

1. **`curl: (3) / syntax error / $'\r'`**: Windows CRLF line ending in `.env`, `.sh`, or `.bp`. Strip with `sed -i 's/\r$//'` and enforce in `.gitattributes`.
2. **`cannot assign to readonly: PRODUCT_*`**: Kati vs Soong phase violation. Product packages must live in `.mk` fragments inherited by `device.mk`, never inside `Android.mk`.
3. **`Killed / soong_build OOM`**: Container RAM/Swap exhaustion. Export `GOMEMLIMIT=14GiB`, `GOGC=40`, and `MALLOC_ARENA_MAX=2`.
4. **`exec format error / missing clang`**: Unexpanded Git LFS pointer text file in prebuilts. Run `repo forall -r "prebuilts/.*" -c "git lfs pull"`.
5. **`VINTF / manifest mismatch`**: HAL interface version mismatch. Invalidate `check_vintf` intermediates and verify matrix compatibility level.
6. **`dexpreopt failed / verify error`**: Prebuilt APK fails dex2oat optimization. Set `dex_preopt: { enabled: false }` in `Android.bp`.

## Core Engineering Rules

### 1. Kati vs Soong Separation (Never put `PRODUCT_*` in `Android.mk`)
- **Product Configuration Phase (Make)**: Reads `device.mk`, `BoardConfig.mk`. `PRODUCT_PACKAGES` and properties are mutable.
- **Soong Phase**: Evaluates all `Android.bp` blueprints and outputs the Ninja graph.
- **Kati Phase**: Kati executes all `Android.mk` files and locks `PRODUCT_*` variables as **read-only**.
- **Rule**: Never assign `PRODUCT_PACKAGES` inside an `Android.mk`. Product package declarations belong in `.mk` fragments inherited from `device.mk`:
  ```makefile
  $(call inherit-product-if-exists, vendor/<name>/aosp/device_<device>.mk)
  ```
  App modules belong in `Android.bp`.

### 2. Line Ending Normalization (`\r\n` vs `\n`)
Windows CRLF endings corrupt bash execution, curl URLs, and sepolicy compilation.
- Enforce in `.gitattributes`:
  ```gitattributes
  * text=auto eol=lf
  *.sh text eol=lf
  *.env text eol=lf
  *.mk text eol=lf
  *.bp text eol=lf
  *.xml text eol=lf
  *.rc text eol=lf
  ```
- Strip defensively in scripts:
  ```bash
  sed -i 's/\r$//' path/*.sh path/*.env 2>/dev/null || true
  ```

### 3. Dexpreopt on Prebuilt APKs
Commercial prebuilts (GCam, Dolby Atmos, microG) often fail `dex2oat` during ROM packaging. Always disable dexpreopt in the `Android.bp`:
```blueprint
android_app_import {
    name: "GoogleCameraEng",
    apk: "GoogleCameraEng.apk",
    product_specific: true,
    privileged: true,
    presigned: true,
    dex_preopt: {
        enabled: false,
    },
}
```

### 4. Container Storage & Memory Management
- **Never rely on `swapon` in unprivileged containers**: Containers on Crave or Docker typically block `swapon` (`Operation not permitted`). Creating a 16GB swapfile on `/` will fail to activate and waste 16GB of container storage, causing `No space left on device`.
- **Clean inactive swapfiles**: Check for dead `/swapfile` from previous aborted runs and remove immediately.
- **Prune Git LFS local cache**: Blobs under `.git/lfs/objects` duplicate gigabytes of storage. Prune with:
  ```bash
  find . -type d -name "objects" -path "*/.git/lfs/objects" -exec rm -rf {} + 2>/dev/null || true
  ```
- **Drop unneeded test targets**: Prevent building unused unit test suites:
  ```bash
  export DONT_INSTALL_DEXPREOPT_TESTS=true
  export SKIP_BOOT_JARS_CHECK=true
  export WITHOUT_CHECK_API=true
  ```

### 5. Incremental Build Preservation
- **Never wipe `out/` unconditionally**: A clean build takes 2 to 4 hours. Incremental builds on Crave (`--no-patch`) finish in minutes by reusing 155,000+ compiled targets.
- **Perform targeted invalidations only**:
  - Kernel: `rm -rf out/target/product/<device>/obj/KERNEL_OBJ`
  - VINTF: `rm -rf out/target/product/<device>/etc/vintf out/target/product/<device>/obj/PACKAGING`
  - SEPolicy: `rm -rf out/soong/.intermediates/system/sepolicy/recovery_sepolicy.*`
  - Test suites & symbols: `rm -rf out/target/product/<device>/symbols out/target/product/<device>/testcases out/dist`

### 6. Clean Scripting Standards
- Avoid linear script spaghetti; structure build automation into distinct functions:
  `clean_workspace()`, `setup_manifests()`, `sync_sources()`, `sync_device_repos()`, `setup_toolchain()`, `cleanup_storage()`, `setup_environment()`, `build_target()`, `upload_artifacts()`.
- Use `set -eo pipefail` and clean error handlers (`die()`).
- Avoid multi-iteration `for` loops running `rm -rf` individual paths; pass paths directly to a single `rm -rf` invocation.

### 7. Branch-Distinct Documentation
When maintaining multiple ROM branches (e.g., `PixelOS-17-base` and `PixelOS-16-QPR2`):
- Documentation, local manifests, and clone commands must accurately reflect the specific branch.
- Avoid cross-branch contamination (e.g. A16 README pointing to an A17 manifest branch).
- Keep README files concise, technical, and free of artificial emoji spam.

## Reference Guides

- [Build Failure Playbook](./references/build_failure_playbook.md) — Failure catalog and solutions.
- [Kati & Soong Rules](./references/kati_soong_rules.md) — Blueprint and makefile rules.
- [Incremental vs. Clean Guide](./references/incremental_vs_clean.md) — Build decision tree.
