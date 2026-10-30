# Android ROM Commit Style Guide

This guide provides good vs. bad examples of commit messages across custom ROM repositories.

---

## 🏷️ Category Examples

### 1. Applications & Services (`LunarisDolby`, `AudioFX`, `Settings`)
- ✅ `LunarisDolby: synchronize Dolby state with Quick Settings tile in real-time`
- ✅ `LunarisDolby: remove credits and contributors from app and documentation`
- ✅ `DolbyTileService: request listening state update on audio routing change`
- ❌ `fixed the bug where the qs tile didnt change when clicked` *(lacks subsystem prefix, past tense, conversational)*

### 2. Device Trees (`device/xiaomi/sweet2`, `sm6150-common`)
- ✅ `sweet2: register GCam package in product configuration`
- ✅ `sweet2: update audio HAL policy for spatializer support`
- ✅ `sm6150-common: update display brightness curve for sunlight mode`
- ❌ `update device.mk for camera` *(missing device prefix and specific detail)*

### 3. Vendor & Prebuilts (`vendor/GCam_sweet2`, `android_prebuilts_sweet2`)
- ✅ `gcam: fix CRLF URL malformat error and enforce LF endings in .gitattributes`
- ✅ `gcam: remove obsolete Android.mk and register package directly in device fragment`
- ✅ `prebuilts: update pinned GCam ENG prebuilt to V52`
- ❌ `fixed gcam url download failure` *(past tense, lacks prefix)*

### 4. SELinux Policies (`sepolicy`)
- ✅ `sepolicy: allow hal_dms_default to access vendor_media_data_file`
- ✅ `sepolicy: enforce UNIX LF line endings across all te files`
- ❌ `added permissions for dolby` *(imprecise, lacks context)*

### 5. Build Scripts & Manifests
- ✅ `build_scripts: sanitize CRLF before executing fetch_gcam_prebuilt`
- ✅ `manifest: bump android_kernel_xiaomi_sm6150 to PixelOS-17-base`
- ❌ `update script` *(too generic)*

---

## 📋 Pre-Commit Checklist

Before executing `git commit`:
- [ ] Working tree is free of `.gradle/`, `.idea/`, `build/`, `local.properties`.
- [ ] `git diff --check` returns zero whitespace / CRLF warnings.
- [ ] `.gitattributes` exists and specifies `* text=auto eol=lf`.
- [ ] Commit subject line is under 72 characters and uses imperative mood.
- [ ] Paired base branches (`PixelOS-17-base` and `PixelOS-16-QPR2`) are scheduled for fast-forward sync.

