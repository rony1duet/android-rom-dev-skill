# Multi-Branch Parity and Branch Isolation Protocol

Custom ROM maintenance often requires tracking multiple Android versions simultaneously:
- `PixelOS-17-base` (Android 17 development branch)
- `PixelOS-16-QPR2` (Android 16 QPR2 release branch)
- `main` / `master` (Default integration or scripts branch)

---

## 1. Shared Code Repositories (Parity via Merge)

When changes apply identically to all releases (e.g., audio HAL configs, device overlay updates, kernel defconfig tweaks in shared device trees):

```bash
# 1. Push changes on working branch
git push origin PixelOS-17-base

# 2. Switch to paired branch
git checkout PixelOS-16-QPR2

# 3. Perform fast-forward merge
git merge PixelOS-17-base

# 4. Push synced branch
git push origin PixelOS-16-QPR2

# 5. Return to primary branch
git checkout PixelOS-17-base
```

---

## 2. Branch-Distinct Repositories (Strict Isolation)

Repositories with version-specific configurations must never be blindly merged across branches:
- Local manifests: Revisions must point to the specific branch (`revision="PixelOS-16-QPR2"` vs `revision="PixelOS-17-base"`).
- Prebuilt manifests: Local clone targets must match the branch.
- Build scripts and documentation: Commands and clone instructions must reference the exact target branch.

### Porting Changes to Branch-Distinct Repositories
Use cherry-picking or manual edits rather than `git merge`:

```bash
# Obtain commit hash from source branch
COMMIT_HASH=$(git log -n 1 --format="%H" PixelOS-17-base)

# Switch to target branch
git checkout PixelOS-16-QPR2

# Cherry-pick without fast-forwarding branch-specific files
git cherry-pick -x "${COMMIT_HASH}"

# Verify branch-specific revisions remain intact
git diff HEAD~1 sweet2.xml

# Push target branch
git push origin PixelOS-16-QPR2

# Return to primary branch
git checkout PixelOS-17-base
```

---

## 3. Verification

For shared repositories, verify matching commit heads:
```bash
git log -n 1 PixelOS-17-base --oneline
git log -n 1 PixelOS-16-QPR2 --oneline
```

For branch-distinct repositories, verify that branch manifests point to the correct revisions:
```bash
git checkout PixelOS-16-QPR2 && grep 'revision=' sweet2.xml
git checkout PixelOS-17-base && grep 'revision=' sweet2.xml
```
