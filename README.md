# 🚀 Antigravity ROM Development Skill Suite

A complete, production-grade **Antigravity Customization Suite** designed for Android Custom ROM engineers (AOSP, PixelOS, LineageOS, CrDroid, etc.).

This suite trains any Antigravity IDE agent on any PC with expert domain knowledge, while **maximizing token efficiency** via progressive disclosure and automated validation scripts.

---

## 📦 What Skills Are Included

The suite provides 3 specialized, modular skills:

```text
skills/
├── android-rom-dev/          # ⚙️ Build Troubleshooting & Architecture
│   ├── SKILL.md              # Compact execution runbook
│   ├── scripts/              # check_rom_build_env.sh, clean_target_intermediates.sh, sanitize_line_endings.sh
│   └── references/           # build_failure_playbook.md, kati_soong_rules.md, incremental_vs_clean.md
│
├── rom-git-commits/          # 📝 Git Commit Standards & Parity Protocol
│   ├── SKILL.md              # Conventional commit rules & pre-commit audit
│   ├── scripts/              # git_precommit_check.sh, sync_rom_branches.sh
│   └── references/           # commit_style_guide.md, branch_sync_protocol.md
│
└── rom-documentation/        # 📄 Technical Documentation & Templates
    ├── SKILL.md              # Structural guidelines & checklist
    └── references/           # device_tree_readme_template.md, module_readme_template.md, changelog_template.md
```

---

## ⚡ How This Suite Saves Context Tokens

1. **Progressive Disclosure**:
   - The agent only sees the short name and trigger description of each skill in its system prompt.
   - If you ask about a **build failure**, only `android-rom-dev` is activated.
   - If you ask to **commit and push**, only `rom-git-commits` is activated.
   - If you ask to **write or update documentation**, only `rom-documentation` is activated.
   - Heavy markdown templates and diagnostic tables in `references/` are loaded **strictly on demand**.
2. **Deterministic Script Execution**:
   - Instead of the agent generating hundreds of tokens of exploratory shell commands to inspect swap, clean intermediates, check git status, or fix CRLF, pre-packaged executable scripts in `scripts/` perform the operations instantly.
3. **Focused Context**:
   - Zero unnecessary context pollution: each skill is decoupled and focused on its specific domain.

---

## 💻 1-Click Installation on Any Machine

### On Windows
Run either option:
- **Option A (Double-click)**: Double-click `install.bat`.
- **Option B (PowerShell)**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\install.ps1
  ```
- *To install only into the current project workspace instead of globally*:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\install.ps1 -Workspace
  ```

### On Linux / macOS
Run the bash installer:
```bash
bash install.sh
```
- *To install only into the current project workspace instead of globally*:
```bash
bash install.sh --workspace
```

---

## 🎯 Skill Highlights

### 1. `android-rom-dev` (Build Engine)
- **Kati vs Soong**: Why `PRODUCT_PACKAGES` inside `Android.mk` causes fatal Kati errors and how to declare packages in device fragments (`.mk`) while modules live in `Android.bp`.
- **CRLF Normalization**: Prevents `curl: (3) URL rejected: Bad query`, bash `$'\r'` syntax errors, and SEPolicy compilation failures.
- **OOM Prevention**: Auto-provisions 16GB swap and exports `GOMEMLIMIT=14GiB` / `GOGC=40` for build containers.
- **Incremental vs Clean**: Matrix to prevent unnecessary 2–4 hour `make clean` wipes.

### 2. `rom-git-commits` (Git Workflow)
- **Conventional Subsystem Tags**: Strict formatting (`LunarisDolby:`, `gcam:`, `sweet2:`, `sepolicy:`) using imperative verbs.
- **Pre-Commit Hygiene**: Automated checks forbidding `.gradle/`, `.idea/`, `local.properties`, test APKs, and debug manifests.
- **Branch Parity**: Fast-forward synchronization between paired releases (`PixelOS-17-base` and `PixelOS-16-QPR2`).

### 3. `rom-documentation` (Documentation Engine)
- **Production README Standards**: Shields.io badges, ASCII architectural directory trees, and hardware support matrix tables.
- **Flashing Runbooks**: Clean flash vs dirty flash instructions, custom recovery, and KernelSU / Magisk installation guides.
- **Standardized Changelogs**: Release notes categorizing changes by subsystem.
