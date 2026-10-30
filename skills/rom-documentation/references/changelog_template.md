# ROM Release Changelog Template

```markdown
# PixelOS for Redmi Note 12 Pro 4G (sweet2) — Changelog

**Build Date**: 2026-10-30  
**Android Version**: 17.0 (PixelOS-17-base)  
**Security Patch**: October 2026  
**Maintainer**: rony1duet  

---

## 🚀 Highlights & New Features

- **Base Upgrade**: Initial bringup on Android 17 (PixelOS-17-base) with unified SM6150 common tree.
- **Dolby Atmos**: Enhanced LunarisDolby with real-time Quick Settings tile state synchronization.
- **Camera Integration**: Prebuilt Google Camera (MGC 9.6.080) with Sweet2 108MP and 4K@30fps profile.
- **Kernel & Root**: KernelSU Next updated to v3.4.2_33355 with native driver hooks.

---

## 🛠️ Detailed Changelog

### Device Specific (`sweet2` & `sm6150-common`)
- `sweet2: register GCam package in product configuration`
- `sm6150-common: update display brightness curve for sunlight mode`
- `sepolicy: enforce UNIX LF line endings across all te files`
- `sepolicy: allow hal_dms_default to access vendor_media_data_file`

### Audio & Dolby (`hardware_dolby`)
- `LunarisDolby: synchronize Dolby state with Quick Settings tile in real-time`
- `LunarisDolby: remove credits and contributors from app and documentation`
- `DolbyTileService: request listening state update on audio routing change`

### Vendor & Prebuilts
- `gcam: fix CRLF URL malformat error and enforce LF endings in .gitattributes`
- `gcam: remove obsolete Android.mk and register package directly in device fragment`
- `build_scripts: sanitize CRLF before executing fetch_gcam_prebuilt`

---

## 📲 Flashing Instructions

1. Reboot to custom recovery (OrangeFox / TWRP / PixelOS Recovery).
2. Wipe Dalvik/ART Cache and Metadata (Format Data required when upgrading Android versions).
3. Flash the ROM zip.
4. Reboot to System.
```

