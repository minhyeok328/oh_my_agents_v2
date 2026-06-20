param(
    [string]$ManifestPath = "workspaces/sample-app/.agent/manifest.yml"
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

function Resolve-RepoPath($path) {
    if ([string]::IsNullOrWhiteSpace($path)) {
        return ""
    }

    $fullPath = if ([System.IO.Path]::IsPathRooted($path)) {
        [System.IO.Path]::GetFullPath($path)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $repoRoot $path))
    }

    $repoFullPath = [System.IO.Path]::GetFullPath($repoRoot)
    if (-not $repoFullPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $repoFullPath = $repoFullPath + [System.IO.Path]::DirectorySeparatorChar
    }

    if (-not $fullPath.StartsWith($repoFullPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        Fail "path is outside repository: $path"
    }

    return $fullPath
}

function Normalize-PathValue($value) {
    if ($null -eq $value) {
        return ""
    }

    return $value.Trim([char[]]@([char]34, [char]39, [char]32)).Replace("\", "/").Trim("/")
}

function Test-PlaceholderValue($value) {
    if ($null -eq $value) {
        return $true
    }

    if ([string]::IsNullOrWhiteSpace($value)) {
        return $true
    }

    return @("TBD", "TODO", "Needs Confirmation", "<fill>", "<todo>") -contains $value.Trim()
}

function Read-SimpleYaml($path) {
    $manifest = @{}
    $section = ""
    $lineNumber = 0

    foreach ($line in Get-Content -Encoding UTF8 -LiteralPath $path) {
        $lineNumber += 1
        $trimmed = $line.Trim()

        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#")) {
            continue
        }

        if ($line -match "^\S[^:]*:\s*(.*)$") {
            $parts = $line -split ":", 2
            $key = $parts[0].Trim()
            $value = $parts[1].Trim()

            if ([string]::IsNullOrWhiteSpace($value)) {
                $section = $key
            }
            else {
                $manifest[$key] = $value.Trim([char[]]@([char]34, [char]39))
                $section = ""
            }
            continue
        }

        if ($line -match "^\s{2}[^:]+:\s*.+$") {
            if ([string]::IsNullOrWhiteSpace($section)) {
                Fail "$path line $lineNumber has nested value without a section"
                continue
            }

            $parts = $trimmed -split ":", 2
            $key = $parts[0].Trim()
            $value = $parts[1].Trim().Trim([char[]]@([char]34, [char]39))
            $manifest["$section.$key"] = $value
            continue
        }

        Fail "$path line $lineNumber is not supported by the simple manifest parser: $line"
    }

    return $manifest
}

function Get-ManifestValue($manifest, $key) {
    if (-not $manifest.ContainsKey($key)) {
        Fail "manifest missing required key: $key"
        return ""
    }

    $value = $manifest[$key]
    if (Test-PlaceholderValue $value) {
        Fail "manifest has empty or placeholder key: $key"
        return ""
    }

    return $value
}

function Get-ProfileField($content, $label) {
    $escaped = [regex]::Escape($label)
    $match = [regex]::Match($content, "(?m)^\s*-\s+$escaped\s*:\s*(.+?)\s*$")
    if ($match.Success) {
        return $match.Groups[1].Value.Trim()
    }

    return ""
}

function Assert-Equals($name, $actual, $expected) {
    if ($actual -ne $expected) {
        Fail "$name mismatch: expected '$expected' but found '$actual'"
    }
}

function Assert-PathUnderWorkspace($name, $path, $activeRoot) {
    $normalized = Normalize-PathValue $path
    if (-not $normalized.StartsWith("$activeRoot/", [System.StringComparison]::OrdinalIgnoreCase) -and $normalized -ne $activeRoot) {
        Fail "$name must be inside active workspace: $path"
    }
}

$manifestFullPath = Resolve-RepoPath $ManifestPath
if (-not (Test-Path -LiteralPath $manifestFullPath -PathType Leaf)) {
    Fail "missing workspace manifest: $ManifestPath"
}
else {
    $manifest = Read-SimpleYaml $manifestFullPath

    Assert-Equals "version" (Get-ManifestValue $manifest "version") "1"

    $activeRoot = Normalize-PathValue (Get-ManifestValue $manifest "workspace.active_root")
    $profilePath = Normalize-PathValue (Get-ManifestValue $manifest "workspace.profile")
    $contractRoot = Normalize-PathValue (Get-ManifestValue $manifest "contracts.root")
    $apiContract = Normalize-PathValue (Get-ManifestValue $manifest "contracts.api")
    $smokeCwd = Normalize-PathValue (Get-ManifestValue $manifest "verification.smoke_cwd")
    $smokeCommand = Get-ManifestValue $manifest "verification.smoke_command"
    $fullCwd = Normalize-PathValue (Get-ManifestValue $manifest "verification.full_cwd")
    $fullCommand = Get-ManifestValue $manifest "verification.full_command"
    $gitMode = Get-ManifestValue $manifest "git.mode"
    $stewardRequired = Get-ManifestValue $manifest "git.steward_required"
    $implementationMayRunGit = Get-ManifestValue $manifest "git.implementation_agents_may_run_git"
    $forbiddenEnvFiles = Get-ManifestValue $manifest "security.real_env_files_forbidden"

    if (-not $activeRoot.StartsWith("workspaces/", [System.StringComparison]::OrdinalIgnoreCase)) {
        Fail "workspace.active_root must be under workspaces/: $activeRoot"
    }
    if ($activeRoot.Contains("..") -or [System.IO.Path]::IsPathRooted($activeRoot)) {
        Fail "workspace.active_root must be repo-relative without traversal: $activeRoot"
    }

    foreach ($directoryPath in @($activeRoot, $contractRoot, $smokeCwd, $fullCwd)) {
        $fullPath = Resolve-RepoPath $directoryPath
        if (-not (Test-Path -LiteralPath $fullPath -PathType Container)) {
            Fail "manifest directory does not exist: $directoryPath"
        }
    }

    foreach ($filePath in @($profilePath, $apiContract)) {
        $fullPath = Resolve-RepoPath $filePath
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            Fail "manifest file does not exist: $filePath"
        }
    }

    foreach ($pathValue in @($profilePath, $contractRoot, $apiContract, $smokeCwd, $fullCwd)) {
        Assert-PathUnderWorkspace "manifest path" $pathValue $activeRoot
    }

    $allowedGitModes = @("shell-owned", "app-owned", "none", "submodule")
    if ($allowedGitModes -notcontains $gitMode) {
        Fail "git.mode must be one of $($allowedGitModes -join ', '): $gitMode"
    }

    if (@("true", "false") -notcontains $stewardRequired) {
        Fail "git.steward_required must be true or false"
    }

    if (@("true", "false") -notcontains $implementationMayRunGit) {
        Fail "git.implementation_agents_may_run_git must be true or false"
    }

    if ($implementationMayRunGit -ne "false") {
        Fail "implementation agents must not be allowed to run Git in this governance fixture"
    }

    foreach ($envFile in ($forbiddenEnvFiles -split ",")) {
        $name = $envFile.Trim()
        if ([string]::IsNullOrWhiteSpace($name)) {
            continue
        }
        if (-not $name.StartsWith(".env")) {
            Fail "security.real_env_files_forbidden should list env files only: $name"
        }
    }

    if (Test-Path -LiteralPath (Resolve-RepoPath $profilePath) -PathType Leaf) {
        $profileContent = Get-Content -Raw -Encoding UTF8 -LiteralPath (Resolve-RepoPath $profilePath)
        Assert-Equals "profile Active root" (Normalize-PathValue (Get-ProfileField $profileContent "Active root")) $activeRoot
        Assert-Equals "profile Contract directory" (Normalize-PathValue (Get-ProfileField $profileContent "Contract directory")) $contractRoot
        Assert-Equals "profile Minimal smoke verification" (Get-ProfileField $profileContent "Minimal smoke verification") $smokeCommand
        Assert-Equals "profile Full verification" (Get-ProfileField $profileContent "Full verification") $fullCommand
        Assert-Equals "profile Git mode" (Get-ProfileField $profileContent "Git mode") $gitMode

        if ($stewardRequired -eq "true") {
            Assert-Equals "profile Git steward" (Get-ProfileField $profileContent "Git steward") "required before commit"
        }
    }
}

if ($failed) {
    Write-Host "Workspace manifest check failed." -ForegroundColor Red
    exit 1
}

Pass "workspace manifest"
