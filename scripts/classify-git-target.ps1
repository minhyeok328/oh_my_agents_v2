param(
    [string]$ActiveWorkspace = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

function Normalize-PathForGit($path) {
    return $path.Replace("\", "/").Trim("/")
}

function Get-StatusPath($line) {
    if ($line.Length -lt 4) {
        return ""
    }

    $path = $line.Substring(3).Trim()
    if ($path.Contains(" -> ")) {
        $parts = $path -split " -> "
        $path = $parts[$parts.Count - 1].Trim()
    }

    return $path.Trim('"')
}

function Test-ForbiddenPath($path) {
    $leaf = Split-Path -Leaf $path
    if ($leaf -like ".env*" -and $leaf -ne ".env.example") {
        return $true
    }

    return ($path -match "(^|/)\.git(/|$)")
}

function Get-PathClass($path, $activeWorkspace) {
    $normalizedPath = Normalize-PathForGit $path

    if (Test-ForbiddenPath $normalizedPath) {
        return "forbidden"
    }

    if ($normalizedPath -eq "workspaces/README.md") {
        return "shell"
    }

    if ($normalizedPath -match "^workspaces/([^/]+)/") {
        if ([string]::IsNullOrWhiteSpace($activeWorkspace)) {
            return "other-app"
        }

        if ($normalizedPath.StartsWith("$activeWorkspace/", [System.StringComparison]::OrdinalIgnoreCase)) {
            return "active-app"
        }

        return "other-app"
    }

    return "shell"
}

if (-not [string]::IsNullOrWhiteSpace($ActiveWorkspace)) {
    $ActiveWorkspace = Normalize-PathForGit $ActiveWorkspace

    if (-not $ActiveWorkspace.StartsWith("workspaces/", [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-Host "Git target: Needs Confirmation"
        Write-Host "Reason: ActiveWorkspace must be under workspaces/"
        exit 1
    }

    if ($ActiveWorkspace.Contains("..") -or [System.IO.Path]::IsPathRooted($ActiveWorkspace)) {
        Write-Host "Git target: Needs Confirmation"
        Write-Host "Reason: ActiveWorkspace must be repo-relative"
        exit 1
    }
}

$statusLines = @(git status --porcelain)
if ($LASTEXITCODE -ne 0) {
    Write-Host "Git target: Needs Confirmation"
    Write-Host "Reason: git status failed"
    exit 1
}

if ($statusLines.Count -eq 0) {
    Write-Host "Git target: none"
    exit 0
}

$pathsByClass = [ordered]@{
    "shell" = New-Object System.Collections.Generic.List[string]
    "active-app" = New-Object System.Collections.Generic.List[string]
    "other-app" = New-Object System.Collections.Generic.List[string]
    "forbidden" = New-Object System.Collections.Generic.List[string]
}

foreach ($line in $statusLines) {
    $path = Get-StatusPath $line
    if ([string]::IsNullOrWhiteSpace($path)) {
        continue
    }

    $class = Get-PathClass $path $ActiveWorkspace
    $pathsByClass[$class].Add((Normalize-PathForGit $path))
}

$hasShell = $pathsByClass["shell"].Count -gt 0
$hasActiveApp = $pathsByClass["active-app"].Count -gt 0
$hasOtherApp = $pathsByClass["other-app"].Count -gt 0
$hasForbidden = $pathsByClass["forbidden"].Count -gt 0

if ($hasForbidden -or $hasOtherApp -or ($hasShell -and $hasActiveApp)) {
    Write-Host "Git target: Needs Confirmation"
}
elseif ($hasActiveApp) {
    Write-Host "Git target: active app"
}
elseif ($hasShell) {
    Write-Host "Git target: shell"
}
else {
    Write-Host "Git target: none"
}

foreach ($class in $pathsByClass.Keys) {
    if ($pathsByClass[$class].Count -eq 0) {
        continue
    }

    Write-Host "${class}:"
    foreach ($path in ($pathsByClass[$class] | Sort-Object -Unique)) {
        Write-Host "- $path"
    }
}

if ($hasForbidden -or $hasOtherApp -or ($hasShell -and $hasActiveApp)) {
    exit 1
}
