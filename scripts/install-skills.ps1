param(
    [string]$CodexHome = (Join-Path $env:USERPROFILE ".codex"),
    [string[]]$Skill = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sourceRoot = Join-Path $repoRoot "docs/skills"
$requestedSkills = @(
    foreach ($name in $Skill) {
        $name -split "," |
            ForEach-Object { $_.Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    }
)

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw "Missing source skills directory: $sourceRoot"
}

$skillDirs = if ($requestedSkills.Count -gt 0) {
    foreach ($name in $requestedSkills) {
        $dir = Join-Path $sourceRoot $name
        if (-not (Test-Path -LiteralPath (Join-Path $dir "SKILL.md") -PathType Leaf)) {
            throw "Missing source skill: $dir"
        }
        Get-Item -LiteralPath $dir
    }
} else {
    Get-ChildItem -LiteralPath $sourceRoot -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") -PathType Leaf } |
        Sort-Object Name
}

foreach ($dir in $skillDirs) {
    $targetDir = Join-Path (Join-Path $CodexHome "skills") $dir.Name
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Copy-Item -LiteralPath (Join-Path $dir.FullName "SKILL.md") -Destination (Join-Path $targetDir "SKILL.md") -Force
    Write-Host "Installed skill: $($dir.Name)"
}
