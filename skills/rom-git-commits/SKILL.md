---
name: rom-git-commits
description: >-
  Standards, commit message conventions, pre-commit hygiene, and multi-branch synchronization
  for Android ROM, device tree, vendor, and hardware repositories. Use when staging files,
  drafting commit messages, committing, pushing to remotes, cleaning unneeded build/IDE artifacts,
  or maintaining parity across paired branches (e.g. PixelOS-17-base and PixelOS-16-QPR2).
---

# Android ROM Git Commit and Branch Synchronization Standards

This guide covers standards for drafting commit messages, performing pre-commit staging cleanup, and maintaining multi-branch ROM trees.

---

## 1. Pre-Commit Staging Hygiene (Forbidden Files)

Never stage or commit temporary, local, or build-generated files:
- Build and IDE caches: `.gradle/`, `.idea/`, `.kotlin/`, `build/`, `out/`, `bin/`, `.cxx/`
- Local configurations: `local.properties`, `gradle.properties`, `settings.gradle` (in pure AOSP packages)
- Test artifacts: `AndroidManifest_debug.xml`, test packages (`*.apk`, `*.aab`), temporary images (`*.png`)
- Binary objects: `.so` libraries unless officially pinned and tracked in a prebuilt vendor tree.

### Quick Sanitize Command
Before running `git add`, purge local build files:
```bash
rm -rf .gradle .idea .kotlin build out 2>/dev/null || true
rm -f AndroidManifest_debug.xml local.properties *.png 2>/dev/null || true
```

Or run the pre-commit audit script:
[git_precommit_check.sh](./scripts/git_precommit_check.sh)

---

## 2. Commit Message Conventions

Follow the AOSP, LineageOS, and PixelOS subsystem prefix convention:

```text
<subsystem>: <imperative summary>

[optional body explaining why the change was necessary]
```

### Subsystem Tags
- Apps and Audio: `LunarisDolby:`, `Aperture:`, `AudioFX:`, `Settings:`
- Device Trees: `<device>:`, `sweet2:`, `sm6150-common:`
- Vendor and Prebuilts: `gcam:`, `vendor:`, `prebuilts:`
- Kernel and HALs: `kernel:`, `sepolicy:`, `hardware:`
- Build Infrastructure: `build_scripts:`, `manifest:`, `soong:`

### Rules
1. Imperative mood: Use "fix", "add", "synchronize", "remove", "update" (not "fixed", "adds", "fixing").
2. Concise summary: Under 72 characters on the first line.
3. No redundant contributors: Keep commit logs focused on technical changes rather than marketing fluff.

For examples, see [Commit Style Guide](./references/commit_style_guide.md).

---

## 3. Multi-Branch Parity and Branch-Distinct Configuration

When maintaining repositories that support multiple Android releases (such as `PixelOS-17-base` and `PixelOS-16-QPR2`):

### A. Shared Code Repositories (Fast-Forward Sync)
For device trees, hardware HALs, and shared vendor components where code is identical across releases:
1. Commit on the active branch:
   ```bash
   git add <files>
   git diff --cached --check
   git commit -m "<subsystem>: <imperative message>"
   git push origin PixelOS-17-base
   ```
2. Fast-forward merge to the paired branch:
   ```bash
   git checkout PixelOS-16-QPR2
   git merge PixelOS-17-base
   git push origin PixelOS-16-QPR2
   git checkout PixelOS-17-base
   ```

### B. Branch-Distinct Repositories (Cherry-Pick / Isolated Commits)
Never blindly fast-forward merge repositories that contain version-specific configurations:
- Manifest repositories (`manifest_sweet2`): Revisions must explicitly point to `PixelOS-17-base` vs `PixelOS-16-QPR2`.
- Prebuilt / camera manifests (`GCam_sweet2`, `android_prebuilts_sweet2`): Branch-specific tracking targets must not be overwritten.
- Build scripts (`build_scripts_sweet2`): Scripts and branch documentation are specific to each Android version.

For branch-distinct repositories:
1. Port common logic via `git cherry-pick -x <commit>` or manual edits.
2. Verify that manifest revisions and clone commands match the checked-out branch.
3. Verify with `git diff --check` before pushing.

See [Branch Sync Protocol](./references/branch_sync_protocol.md) for details.

---

## 4. Pre-Commit Checklist
- Working tree is free of IDE caches (`.idea/`, `.gradle/`) and build outputs.
- `git diff --cached --check` returns zero whitespace or CRLF warnings.
- `.gitattributes` enforces `* text=auto eol=lf`.
- Commit subject line is under 72 characters with an imperative subsystem prefix.
- Branch-distinct files maintain their branch-specific revisions and URLs.
