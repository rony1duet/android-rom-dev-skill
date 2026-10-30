# Device Tree Template (`device/xiaomi/<device>`)

```markdown
# Xiaomi Redmi Note 12 Pro 4G (sweet2) Device Tree

[![Android](https://img.shields.io/badge/Platform-Android_17-green.svg)](https://android.com)
[![Device](https://img.shields.io/badge/Device-sweet2-orange.svg)](https://github.com/rony1duet)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

The **Redmi Note 12 Pro 4G** (codename `sweet2` / `k6a`) is a mid-range smartphone announced by Xiaomi in April 2023.

---

## 📱 Hardware Specifications

| Component | Specification |
| :--- | :--- |
| **SoC** | Qualcomm Snapdragon 732G (SM6150) |
| **CPU** | Octa-core (2x2.3 GHz Kryo 470 Gold & 6x1.8 GHz Kryo 470 Silver) |
| **GPU** | Adreno 618 |
| **Memory** | 6GB / 8GB LPDDR4X |
| **Storage** | 128GB / 256GB UFS 2.2 |
| **Display** | 6.67" AMOLED, 120Hz, Dolby Vision, 1080 x 2400 pixels |
| **Rear Camera** | 108 MP (wide) + 8 MP (ultrawide) + 2 MP (macro) + 2 MP (depth) |
| **Front Camera** | 16 MP |
| **Battery** | 5000 mAh, 67W wired fast charging |

---

## 🛠️ Build Runbook

### 1. Initialize Local Manifest
Add the sweet2 manifests to `.repo/local_manifests/sweet2.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
    <project path="device/xiaomi/sweet2" name="rony1duet/android_device_xiaomi_sweet2" remote="rem" revision="PixelOS-17-base" />
    <project path="device/xiaomi/sm6150-common" name="rony1duet/android_device_xiaomi_sm6150-common" remote="rem" revision="PixelOS-17-base" />
</manifest>
```

### 2. Sync Source Tree
```bash
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

### 3. Compile the ROM
```bash
source build/envsetup.sh
breakfast sweet2
m pixelos
```
```

