# Incremental vs. Clean Build Decision Guide

One of the most common pitfalls in custom ROM development is reflexively running `make clean` (or deleting the `out/` folder) after a build failure. 

A full clean build forces the build system to recompile the entire Android platform, framework libraries, native daemons, and system apps from scratch, wasting **2 to 4+ hours** per attempt.

---

## ⚡ Fast Decision Matrix

| Change or Failure Encountered | Clean `out/` Needed? | Recommended Action |
| :--- | :---: | :--- |
| **Kati `error: cannot assign to readonly variable`** | ❌ **NO** | Fix makefile / delete `Android.mk`. Run build immediately. |
| **`Android.bp` syntax error / missing module** | ❌ **NO** | Fix blueprint. Soong regenerates Ninja rules automatically. |
| **Shell script failure / download failure** | ❌ **NO** | Fix script / URL. Soong cache is completely intact. |
| **CRLF line endings fixed** | ❌ **NO** | Re-run script / build. No compilation cache affected. |
| **Device `.mk` / `BoardConfig.mk` edits** | ❌ **NO** | Kati re-evaluates product config incrementally. |
| **Kernel config change or patch** | ⚠️ **Selective** | Clean kernel object directory only. |
| **VINTF manifest / compatibility matrix bump** | ⚠️ **Selective** | Wipe `check_vintf` intermediate folder only. |
| **SEPolicy rule change / compile failure** | ⚠️ **Selective** | Wipe `recovery_sepolicy.*` and policy intermediates only. |
| **Android major version jump (e.g. A16 -> A17)** | ✅ **YES** | Full clean build required. |
| **Switching release keys / signing keys** | ⚠️ **Installclean**| Run `m installclean` (removes installed output images only). |

---

## 🧹 Targeted Selective Cleaning Commands

Instead of `rm -rf out`, use surgical cleanup commands:

### 1. Kernel Intermediate Cleanup
When changing defconfig, kernel source drivers, or KernelSU patches:
```bash
rm -rf out/target/product/<device>/obj/KERNEL_OBJ
```

### 2. VINTF Verification Intermediate Cleanup
When adding or updating vendor/hardware HAL manifests:
```bash
rm -rf out/target/product/<device>/obj/PACKAGING/check_vintf_all_intermediates
rm -f out/target/product/<device>/vendor/etc/vintf/manifest.xml
```

### 3. SELinux Policy Intermediate Cleanup
When modifying `.te`, file contexts, or sepolicy macros:
```bash
rm -rf out/soong/.intermediates/system/sepolicy/recovery_sepolicy.*
rm -f out/soong/.intermediates/system/sepolicy/tools/version_policy/*/obj/system/sepolicy/tools/version_policy.o
```

### 4. Fast Image Relink (`m installclean`)
Removes installed files in `out/target/product/<device>/system/`, `vendor/`, `product/`, and target partition images (`.img`), but preserves all compiled C/C++ object files, libraries, and Java classes:
```bash
m installclean
```
Takes ~1 minute instead of hours.

