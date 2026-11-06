# Android ROM Commit Style Guide

This guide provides examples of conventional commit messages across custom ROM repositories.

---

## Commit Format

```text
<subsystem>: <imperative summary>

[optional body explaining context or issue reference]
```

---

## Category Examples

### 1. Applications and Services (LunarisDolby, AudioFX, Settings)
- `LunarisDolby: synchronize Dolby state with Quick Settings tile in real-time`
- `LunarisDolby: remove credits and contributors from app and documentation`
- `DolbyTileService: request listening state update on audio routing change`
- Avoid: `fixed the bug where the qs tile didnt change when clicked` (lacks subsystem prefix, uses past tense)

### 2. Device Trees (device/xiaomi/sweet2, sm6150-common)
- `sweet2: register GCam package in product configuration`
- `sweet2: update audio HAL policy for spatializer support`
- `sm6150-common: update display brightness curve for sunlight mode`
- Avoid: `update device.mk for camera` (missing device prefix and specific detail)

### 3. Vendor and Prebuilts (vendor/GCam_sweet2, android_prebuilts_sweet2)
- `gcam: fix CRLF URL malformat error and enforce LF endings in .gitattributes`
- `gcam: remove obsolete Android.mk and register package directly in device fragment`
- `prebuilts: update pinned GCam ENG prebuilt to V52`
- Avoid: `fixed gcam url download failure` (past tense, lacks prefix)

### 4. SELinux Policies (sepolicy)
- `sepolicy: allow hal_dms_default to access vendor_media_data_file`
- `sepolicy: enforce UNIX LF line endings across all te files`
- Avoid: `added permissions for dolby` (imprecise, lacks context)

### 5. Build Scripts and Manifests
- `build_scripts: sanitize CRLF before executing fetch_gcam_prebuilt`
- `manifest: bump android_kernel_xiaomi_sm6150 to PixelOS-17-base`
- Avoid: `update script` (too generic)

---

## Pre-Commit Checklist

Before committing:
- Working tree is clean of `.gradle/`, `.idea/`, `build/`, `local.properties`.
- `git diff --cached --check` reports no whitespace or CRLF warnings.
- `.gitattributes` specifies `* text=auto eol=lf`.
- Commit subject line is under 72 characters and uses imperative mood.
- Branch-distinct files maintain their respective branch targets.
