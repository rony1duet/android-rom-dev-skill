# Android ROM Development Skill Suite

A skill suite for Antigravity IDE and agents working on custom Android ROMs (AOSP, PixelOS, LineageOS, CrDroid, etc.).

The suite provides domain knowledge and automation scripts for diagnosing build failures, enforcing pre-commit hygiene, managing container build environments, and maintaining multi-branch repositories.

---

## Included Skills

```text
skills/
├── android-rom-dev/          # Build troubleshooting and build environment tooling
│   ├── SKILL.md              # Core runbook for build and environment issues
│   ├── scripts/              # check_rom_build_env.sh, clean_target_intermediates.sh, sanitize_line_endings.sh
│   └── references/           # build_failure_playbook.md, kati_soong_rules.md, incremental_vs_clean.md
│
└── rom-git-commits/          # Commit conventions and branch parity protocol
    ├── SKILL.md              # Conventional commits and pre-commit audit
    ├── scripts/              # git_precommit_check.sh, sync_rom_branches.sh
    └── references/           # commit_style_guide.md, branch_sync_protocol.md
```

---

## Skill Overviews

### 1. `android-rom-dev`
- **Build Troubleshooting**: Diagnoses Kati, Soong, Ninja, and SEPolicy compilation errors.
- **Line Endings**: Identifies and fixes CRLF line ending errors that break shell scripts, build configuration fragments, and SELinux file contexts.
- **Environment and Memory**: Inspects container swap, cleans dead swapfiles, and exports memory limits (`GOMEMLIMIT`, `GOGC`) to avoid OOM killer terminations during Java/Go link phases.
- **Target Intermediates**: Cleans corrupt build artifacts without triggering full source tree wipes.

### 2. `rom-git-commits`
- **Subsystem Conventions**: Standardizes commit messages using subsystem prefixes (`sweet2:`, `LunarisDolby:`, `gcam:`, `sepolicy:`) and imperative verbs.
- **Pre-Commit Hygiene**: Verifies that IDE caches (`.idea/`, `.gradle/`), build outputs, local configs, and trailing whitespaces are not staged.
- **Branch Parity & Isolation**: Provides workflows for fast-forwarding shared codebases across releases while keeping version-specific configurations (manifest revisions, branch-specific build scripts) isolated.

---

## Installation

### Windows
Run PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

To install only for the current workspace instead of globally:
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Workspace
```

Alternatively, run `install.bat`.

### Linux / macOS
Run the bash script:
```bash
bash install.sh
```

To install only for the current workspace:
```bash
bash install.sh --workspace
```
