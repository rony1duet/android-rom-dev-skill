<#
.SYNOPSIS
    Installs the Android ROM Development Skill Suite into Antigravity IDE on Windows.
.DESCRIPTION
    Installs:
      - android-rom-dev      (AOSP build troubleshooting, Kati/Soong, OOM, prebuilts)
      - rom-git-commits      (Conventional commits, pre-commit audit, branch sync)
      - rom-documentation    (Markdown standards, device specs, architecture trees)
.PARAMETER Workspace
    Installs only into the current project workspace (.agents\skills\) instead of globally.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install.ps1
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -Workspace
#>
param (
    [switch]$Workspace
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsDir = Join-Path $ScriptDir "skills"

if (-not (Test-Path $SkillsDir)) {
    Write-Error "Skills directory '$SkillsDir' not found!"
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Installing Android ROM Skills Suite for Antigravity IDE" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$GlobalRoot1 = Join-Path $env:USERPROFILE ".gemini\config\skills"
$GlobalRoot2 = Join-Path $env:USERPROFILE ".gemini\antigravity\skills"
$WorkspaceRoot = Join-Path (Get-Location) ".agents\skills"

$SkillFolders = Get-ChildItem -Directory -Path $SkillsDir | Where-Object {
    Test-Path (Join-Path $_.FullName "SKILL.md")
}

foreach ($skill in $SkillFolders) {
    $SkillName = $skill.Name
    Write-Host ""
    Write-Host "[*] Installing skill: $SkillName..." -ForegroundColor Yellow

    if ($Workspace) {
        $Dest = Join-Path $WorkspaceRoot $SkillName
        if (-not (Test-Path $Dest)) {
            New-Item -ItemType Directory -Path $Dest -Force | Out-Null
        }
        Copy-Item -Path "$($skill.FullName)\*" -Destination $Dest -Recurse -Force
        Write-Host "    [OK] Installed into workspace: $Dest" -ForegroundColor Green
    } else {
        foreach ($root in @($GlobalRoot1, $GlobalRoot2)) {
            $Dest = Join-Path $root $SkillName
            if (-not (Test-Path $Dest)) {
                New-Item -ItemType Directory -Path $Dest -Force | Out-Null
            }
            Copy-Item -Path "$($skill.FullName)\*" -Destination $Dest -Recurse -Force
            Write-Host "    [OK] Installed to: $Dest" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "[SUCCESS] Skill Suite Installation Complete!" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Antigravity IDE will now automatically discover and activate:"
Write-Host "  1. android-rom-dev   - For build debugging, Soong/Kati, and OOM issues."
Write-Host "  2. rom-git-commits   - For commit messages, pre-commit checks, and branch parity."
Write-Host "  3. rom-documentation - For device trees, READMEs, and changelogs."
Write-Host ""
Write-Host "Progressive disclosure saves tokens automatically: each skill loads" -ForegroundColor Yellow
Write-Host "into context only when its specific workflow is triggered!" -ForegroundColor Yellow
