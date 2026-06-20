param(
    [string]$ProfilePath = "docs/templates/WORKSPACE_PROFILE.template.md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

$failed = $false

function Pass($message) {
    Write-Host "[ok] $message"
}

function Fail($message) {
    Write-Host "[fail] $message" -ForegroundColor Red
    $script:failed = $true
}

function Resolve-ProfilePath($path) {
    if ([System.IO.Path]::IsPathRooted($path)) {
        return [System.IO.Path]::GetFullPath($path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $path))
}

function Test-UnderRepo($fullPath) {
    $repoFullPath = [System.IO.Path]::GetFullPath($repoRoot)
    if (-not $repoFullPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $repoFullPath = $repoFullPath + [System.IO.Path]::DirectorySeparatorChar
    }

    if (-not $fullPath.StartsWith($repoFullPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        Fail "profile path is outside repository: $fullPath"
    }
}

function Get-RelativePathUnderRepo($fullPath) {
    $repoFullPath = [System.IO.Path]::GetFullPath($repoRoot)
    if (-not $repoFullPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $repoFullPath = $repoFullPath + [System.IO.Path]::DirectorySeparatorChar
    }

    $normalizedFullPath = [System.IO.Path]::GetFullPath($fullPath)
    if ($normalizedFullPath.StartsWith($repoFullPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $normalizedFullPath.Substring($repoFullPath.Length)
    }

    return $normalizedFullPath
}

function Get-FieldValue($content, $label) {
    $escaped = [regex]::Escape($label)
    $match = [regex]::Match($content, "(?m)^\s*-\s+$escaped\s*:\s*(.+?)\s*$")
    if ($match.Success) {
        return $match.Groups[1].Value.Trim(" ", "`t", "`r", "`n", "`"")
    }

    return ""
}

function Test-AppProfilePath($fullPath) {
    $relativePath = Get-RelativePathUnderRepo $fullPath
    $normalized = $relativePath.Replace("/", "\")

    if (-not $normalized.StartsWith("workspaces\", [System.StringComparison]::OrdinalIgnoreCase)) {
        Fail "app profile must live under workspaces/: $relativePath"
    }

    if (-not $normalized.EndsWith("\.agent\profile.md", [System.StringComparison]::OrdinalIgnoreCase)) {
        Fail "app profile must end with .agent\profile.md: $relativePath"
    }
}

function Test-ProfileContent($path, $content) {
    $requiredSections = @(
        "## Identity",
        "## Stack Snapshot",
        "## Commands",
        "## Environment",
        "## Implementation Boundaries",
        "## Contracts",
        "## Verification Notes",
        "## Git Pointer",
        "## Agent Notes"
    )

    foreach ($section in $requiredSections) {
        if (-not $content.Contains($section)) {
            Fail "$path missing required section: $section"
        }
    }

    $requiredPhrases = @(
        "profile.md is authoritative",
        "app-local AGENTS.md is optional",
        "Active root:",
        "Forbidden paths:",
        "Real env files agents must not read:",
        "Git steward:"
    )

    foreach ($phrase in $requiredPhrases) {
        if (-not $content.Contains($phrase)) {
            Fail "$path missing required phrase: $phrase"
        }
    }
}

function Test-AppProfileContent($path, $content) {
    $activeRoot = Get-FieldValue $content "Active root"
    if ([string]::IsNullOrWhiteSpace($activeRoot)) {
        Fail "$path missing filled Active root"
        return
    }

    $normalizedActiveRoot = $activeRoot.Replace("\", "/").Trim("/")
    if (-not $normalizedActiveRoot.StartsWith("workspaces/", [System.StringComparison]::OrdinalIgnoreCase)) {
        Fail "$path Active root must be under workspaces/: $activeRoot"
    }

    if ($normalizedActiveRoot.Contains("..") -or [System.IO.Path]::IsPathRooted($normalizedActiveRoot)) {
        Fail "$path Active root must be repo-relative without traversal: $activeRoot"
    }

    $activeRootPath = Join-Path $repoRoot ($normalizedActiveRoot.Replace("/", "\"))
    if (-not (Test-Path -LiteralPath $activeRootPath -PathType Container)) {
        Fail "$path Active root does not exist: $activeRoot"
    }

    foreach ($field in @("Git mode", "Git root", "Git steward", "Contract directory", "Minimal smoke verification")) {
        $value = Get-FieldValue $content $field
        if ([string]::IsNullOrWhiteSpace($value) -or $value -eq "Needs Confirmation") {
            Fail "$path has empty or unresolved field: $field"
        }
    }
}

if ([string]::IsNullOrWhiteSpace($ProfilePath)) {
    $ProfilePath = "docs/templates/WORKSPACE_PROFILE.template.md"
}

$fullPath = Resolve-ProfilePath $ProfilePath
Test-UnderRepo $fullPath

if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
    Fail "missing workspace profile: $ProfilePath"
}
else {
    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $fullPath
    Test-ProfileContent $ProfilePath $content

    $defaultTemplate = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "docs/templates/WORKSPACE_PROFILE.template.md"))
    if (-not $fullPath.Equals($defaultTemplate, [System.StringComparison]::OrdinalIgnoreCase)) {
        Test-AppProfilePath $fullPath
        Test-AppProfileContent $ProfilePath $content
    }
}

if ($failed) {
    Write-Host "Workspace profile check failed." -ForegroundColor Red
    exit 1
}

Pass "workspace profile"
