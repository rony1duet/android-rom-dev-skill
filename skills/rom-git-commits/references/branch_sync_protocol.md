# Multi-Branch Parity Protocol for ROM Trees

In custom ROM maintenance, device/vendor/hardware repositories often track multiple Android version releases simultaneously:
- `PixelOS-17-base` (Android 17 development branch)
- `PixelOS-16-QPR2` (Android 16 QPR2 stable branch)
- `main` / `master` (Default integration or scripts branch)

When a fix or feature is device-agnostic or applies across both Android versions, both branches must remain in exact 100% parity to avoid regressions.

---

## 🚀 Two-Branch Sync Procedure

Assuming work is committed on `PixelOS-17-base`:

```bash
# Step 1: Ensure current branch is pushed
git push origin PixelOS-17-base

# Step 2: Switch to target paired branch
git checkout PixelOS-16-QPR2

# Step 3: Perform fast-forward merge
git merge PixelOS-17-base

# Step 4: Push synced target branch to origin
git push origin PixelOS-16-QPR2

# Step 5: Return to working branch
git checkout PixelOS-17-base
```

---

## ⚡ Handling Merge Divergence (Cherry-Picking)

If branches have diverged and fast-forward is not possible:

```bash
# Capture the commit hash from source branch
COMMIT_HASH=$(git log -n 1 --format="%H" PixelOS-17-base)

git checkout PixelOS-16-QPR2
git cherry-pick -x "${COMMIT_HASH}"
git push origin PixelOS-16-QPR2
git checkout PixelOS-17-base
```

---

## 🔍 Verification

Verify both branch heads point to identical commits:
```bash
git log -n 1 PixelOS-17-base --oneline
git log -n 1 PixelOS-16-QPR2 --oneline
```
Output must display matching commit subjects.

