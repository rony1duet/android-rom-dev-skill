# Android ROM Build Failure Playbook

This reference manual documents specific error signatures encountered during custom ROM development (AOSP, PixelOS, LineageOS), their underlying root causes, and verified solutions.

---

## 1. Kati Read-Only Variable Assignment

### Error Signature
```text
FAILED:
In file included from hardware/.../Android.mk:1:
vendor/.../Android.mk:5: error: cannot assign to readonly variable: PRODUCT_PACKAGES
14:29:59 kati failed with: exit status 1
```

### Cause
In AOSP, build execution is divided into three distinct phases:
1. **Product Configuration**: Parses `device.mk`, `BoardConfig.mk`, `AndroidProducts.mk`. In this phase, `PRODUCT_PACKAGES`, `PRODUCT_COPY_FILES`, and `PRODUCT_PROPERTY_OVERRIDES` are populated.
2. **Soong Blueprint Analysis**: Parses `Android.bp` files and creates `out/soong/build.<product>.ninja`.
3. **Kati Make Phase**: Kati freezes all `PRODUCT_*` variables as **read-only** to ensure product configuration cannot be mutated midway through dependency graph generation. Kati then scans every folder in the tree and includes every file named `Android.mk`.

When an `Android.mk` attempts `PRODUCT_PACKAGES += ...`, Kati aborts immediately.

### Permanent Fix
1. Delete or remove the `Android.mk` file if the module is already declared in `Android.bp`.
2. Move `PRODUCT_PACKAGES += <ModuleName>` to a device makefile fragment (`.mk`) included from `device.mk`:
   ```makefile
   # in vendor/<app>/aosp/device_<app>.mk:
   PRODUCT_PACKAGES += \
       MyCustomPackage
   ```
3. In `device.mk`:
   ```makefile
   $(call inherit-product-if-exists, vendor/<app>/aosp/device_<app>.mk)
   ```

---

## 2. CRLF Line Endings in Shell Scripts & Environment Files

### Error Signature
```text
curl: (3) URL rejected: Bad query
bash: $'\r': command not found
/bin/sh: ./fetch.sh: /bin/bash^M: bad interpreter: No such file or directory
```

### Cause
Files created or edited on Windows machines default to CRLF line terminators (`0x0D 0x0A` or `\r\n`). When a shell script or `.env` file containing CRLF is executed in Linux:
- `URL="https://pixeldrain.com/api/file/feXtkeQy?download"` becomes `URL="https://pixeldrain.com/api/file/feXtkeQy?download\r"`
- Modern `curl` (version 8+) validates URL characters strictly and rejects raw `\r` control characters with `(3) URL rejected: Bad query`.

### Permanent Fix
1. Add `.gitattributes` to enforce UNIX line endings across Git:
   ```gitattributes
   * text=auto eol=lf
   *.sh text eol=lf
   *.env text eol=lf
   *.mk text eol=lf
   *.bp text eol=lf
   *.xml text eol=lf
   ```
2. Defensively sanitize environment variables inside bash scripts:
   ```bash
   if [[ -f "${SCRIPT_DIR}/config.env" ]]; then
     eval "$(tr -d '\r' < "${SCRIPT_DIR}/config.env")"
   fi
   MY_VAR="${MY_VAR%$'\r'}"
   ```
3. Run `sed` normalization before execution:
   ```bash
   sed -i 's/\r$//' path/to/*.sh path/to/*.env 2>/dev/null || true
   ```

---

## 3. Container Out-Of-Memory (OOM) Killer on `soong_build`

### Error Signature
```text
[ 66% 4/6] analyzing Android.bp files and generating ninja file
Killed
ninja: build stopped: subcommand failed.
```

### Cause
In Android 14+ / 16 / 17, Soong parses thousands of `Android.bp` files concurrently in Go. In Docker containers or build environments with constrained memory (e.g. 16GB RAM) and negligible swap, the Linux kernel invokes the OOM killer (`dmesg: Out of memory: Killed process soong_build`).

### Permanent Fix
1. Automatically provision a 16GB swap file if total swap is under 8GB:
   ```bash
   TOTAL_SWAP_MB=$(free -m 2>/dev/null | awk '/^Swap:/ {print $2}')
   if [ -n "$TOTAL_SWAP_MB" ] && [ "$TOTAL_SWAP_MB" -lt 8192 ]; then
       echo "Provisioning 16GB swapfile..."
       sudo fallocate -l 16G /swapfile 2>/dev/null || sudo dd if=/dev/zero of=/swapfile bs=1M count=16384 2>/dev/null || true
       sudo chmod 600 /swapfile 2>/dev/null || true
       sudo mkswap /swapfile 2>/dev/null || true
       sudo swapon /swapfile 2>/dev/null || true
   fi
   ```
2. Tune Go runtime GC threshold and Soong memory allocation:
   ```bash
   export GOGC=40
   export GOMEMLIMIT=14GiB
   export MALLOC_ARENA_MAX=2
   export SOONG_GOGC=40
   export SOONG_INCREMENTAL_ANALYSIS=false
   ```

---

## 4. Git LFS Pointer Binary Execution Failure

### Error Signature
```text
prebuilts/clang/host/linux-x86/clang-r584948b/bin/clang: cannot execute binary file: Exec format error
```

### Cause
Prebuilt host compilers (Clang, Rust, LLVM tools) are stored via Git Large File Storage (LFS). When checked out with standard git without git-lfs filters installed, the file on disk is an ASCII pointer (~130 bytes):
```text
version https://git-lfs.github.com/spec/v1
oid sha256:28ffb2ddf0a04ac9c01dd38b2dcd4d0615902f20...
size 3805269
```

### Permanent Fix
Run `git lfs pull` inside the relevant prebuilts directory:
```bash
git -C prebuilts/clang/host/linux-x86 lfs pull
git -C prebuilts/rust lfs pull
```
Verify the file is a true 64-bit ELF executable:
```bash
file prebuilts/clang/host/linux-x86/clang-r*/bin/clang
```

---

## 5. Dexpreopt Failures on Prebuilt System Apps

### Error Signature
```text
FAILED: out/target/product/.../dexpreopt_bootjars/.../boot.art
dex2oat failed: Command '['dex2oat', ...]' returned non-zero exit status 1
```

### Cause
Prebuilt APKs (such as vendor camera apps, GCam mods, Dolby Atmos, or proprietary gallery apps) often already contain optimized DEX bytecode, multidex indices, or references to framework methods not in the target AOSP boot image. When Soong tries to run `dex2oat` on them, it fails.

### Permanent Fix
In `Android.bp`, explicitly disable `dex_preopt`:
```blueprint
android_app_import {
    name: "MyPrebuiltApp",
    apk: "app.apk",
    product_specific: true,
    privileged: true,
    presigned: true,
    dex_preopt: {
        enabled: false,
    },
}
```

---

## 6. Prebuilt Apps with Bundled Native Libraries (`.so`)

### Problem
Prebuilt applications often ship with bundled native `.so` files in `lib/arm64-v8a/`. If not extracted to the target directory or not declared properly, the app crashes at runtime with `UnsatisfiedLinkError`.

### Permanent Fix
1. Extract libraries into the designated library directory (`lib/arm64`):
   ```bash
   unzip -j -o "$APK_PATH" 'lib/arm64-v8a/*.so' -d "$DEST_DIR/lib/arm64"
   ```
2. In `Android.bp`, do **not** declare duplicate `cc_prebuilt_library_shared` for native libraries bundled inside an `android_app_import` APK. Soong handles extraction directly when `apk:` is provided.

---

## 7. AudioEffect `@hide` NoSuchFieldError / NoSuchMethodError

### Error Signature
```text
java.lang.NoSuchFieldError: No field EFFECT_TYPE_NULL of type Ljava/util/UUID; in class Landroid/media/audiofx/AudioEffect;
java.lang.NoSuchMethodError: No virtual method getParameter(I[B)I in class Landroid/media/audiofx/AudioEffect;
```

### Cause
`AudioEffect.EFFECT_TYPE_NULL`, `getParameter`, and `setParameter` are `@hide` APIs in AOSP. While system apps signed with platform keys and running inside the ROM build can access `@hide` APIs, non-system testing or non-standard classloaders throw reflection or linkage errors.

### Permanent Fix
In Kotlin/Java audio wrappers:
1. Provide an explicit fallback UUID for null effect types:
   ```kotlin
   companion object {
       private val EFFECT_TYPE_NULL = UUID.fromString("ec714c1f-058f-4210-bf81-7172653321cf")
   }
   ```
2. When testing test builds on device over ADB, temporarily permit hidden APIs:
   ```bash
   adb shell settings put global hidden_api_policy 1
   ```
   Reset when testing concludes:
   ```bash
   adb shell settings delete global hidden_api_policy
   ```

