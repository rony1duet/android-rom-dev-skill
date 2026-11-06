#!/usr/bin/env bash
# ==============================================================================
# Installer: install.sh (Linux / macOS)
# Purpose: Installs the Android ROM Development skill suite into Antigravity IDE.
# Included Skills:
#   - android-rom-dev      (AOSP build troubleshooting, Kati/Soong, OOM, prebuilts)
#   - rom-git-commits      (Conventional commits, pre-commit audit, branch sync)
#
# Usage:
#   Global install (recommended):   ./install.sh
#   Project workspace install:      ./install.sh --workspace
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${SCRIPT_DIR}/skills"

if [ ! -d "${SKILLS_DIR}" ]; then
    echo "[ERROR] Skills directory '${SKILLS_DIR}' not found!"
    exit 1
fi

IS_WORKSPACE=0
if [[ "${1:-}" == "--workspace" || "${1:-}" == "-w" ]]; then
    IS_WORKSPACE=1
fi

echo "=========================================================="
echo "Installing Android ROM Skills Suite for Antigravity IDE"
echo "=========================================================="

# Destination paths
GLOBAL_ROOT_1="${HOME}/.gemini/config/skills"
GLOBAL_ROOT_2="${HOME}/.gemini/antigravity/skills"
WORKSPACE_ROOT="$(pwd)/.agents/skills"

for skill_path in "${SKILLS_DIR}"/*; do
    if [ -d "${skill_path}" ] && [ -f "${skill_path}/SKILL.md" ]; then
        skill_name="$(basename "${skill_path}")"
        echo ""
        echo "Installing skill: ${skill_name}..."

        # Ensure executable permissions on any scripts
        if [ -d "${skill_path}/scripts" ]; then
            chmod +x "${skill_path}/scripts/"*.sh 2>/dev/null || true
        fi

        if [ "$IS_WORKSPACE" -eq 1 ]; then
            dest="${WORKSPACE_ROOT}/${skill_name}"
            mkdir -p "${dest}"
            cp -r "${skill_path}/"* "${dest}/"
            echo "   Installed into workspace: ${dest}"
        else
            mkdir -p "${GLOBAL_ROOT_1}/${skill_name}"
            cp -r "${skill_path}/"* "${GLOBAL_ROOT_1}/${skill_name}/"
            echo "   Installed to: ${GLOBAL_ROOT_1}/${skill_name}"

            mkdir -p "${GLOBAL_ROOT_2}/${skill_name}"
            cp -r "${skill_path}/"* "${GLOBAL_ROOT_2}/${skill_name}/"
            echo "   Installed to: ${GLOBAL_ROOT_2}/${skill_name}"
        fi
    fi
done

echo ""
echo "=========================================================="
echo "Skill Suite Installation Complete"
echo "=========================================================="
echo "Antigravity IDE will now discover and activate:"
echo "  1. android-rom-dev   - Build debugging, Soong/Kati, and environment issues."
echo "  2. rom-git-commits   - Commit messages, pre-commit checks, and branch parity."
echo ""
echo "Skills load into context on demand when triggered."
