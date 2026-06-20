param(
    [string]$TaskCardPath = "",
    [string]$ChecklistPath = "",
    [string[]]$ContractPath = @(),
    [switch]$AllowNeedsConfirmation,
    [switch]$StrictChecklist
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

function Warn($message) {
    Write-Host "[warn] $message" -ForegroundColor Yellow
}

function Resolve-RepoFile($path) {
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
        return $fullPath
    }

    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        Fail "missing file: $path"
    }

    return $fullPath
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

function Get-DisplayPath($fullPath) {
    if ([string]::IsNullOrWhiteSpace($fullPath)) {
        return ""
    }

    $repoFullPath = [System.IO.Path]::GetFullPath($repoRoot)
    if (-not $repoFullPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $repoFullPath = $repoFullPath + [System.IO.Path]::DirectorySeparatorChar
    }

    $normalizedFullPath = [System.IO.Path]::GetFullPath($fullPath)
    if ($normalizedFullPath.StartsWith($repoFullPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $normalizedFullPath.Substring($repoFullPath.Length).Replace("\", "/")
    }

    return $normalizedFullPath
}

function Read-RepoFile($path) {
    $fullPath = Resolve-RepoFile $path
    if ([string]::IsNullOrWhiteSpace($fullPath) -or -not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        return @{ Path = $path; FullPath = $fullPath; Content = "" }
    }

    return @{
        Path = Get-DisplayPath $fullPath
        FullPath = $fullPath
        Content = Get-Content -Raw -Encoding UTF8 -LiteralPath $fullPath
    }
}

function Get-Section($content, $heading) {
    $pattern = '(?ms)^##\s+' + [regex]::Escape($heading) + '(?:\s+\([^)]+\))?\s*$([\s\S]*?)(?=^##\s+|\z)'
    $match = [regex]::Match($content, $pattern)
    if (-not $match.Success) {
        return ""
    }

    return $match.Groups[1].Value
}

function Assert-Heading($path, $content, $heading) {
    $pattern = "(?m)^##\s+" + [regex]::Escape($heading) + "(?:\s+\([^)]+\))?\s*$"
    if (-not ([regex]::IsMatch($content, $pattern))) {
        Fail "$path missing heading: ## $heading"
    }
}

function Get-FieldValue($content, $label) {
    $escaped = [regex]::Escape($label)
    $patterns = @(
        "(?m)^\s*-\s+$escaped\s*:\s*(.+?)\s*$",
        "(?m)^\s*$escaped\s*:\s*(.+?)\s*$"
    )

    foreach ($pattern in $patterns) {
        $match = [regex]::Match($content, $pattern)
        if ($match.Success) {
            return $match.Groups[1].Value.Trim()
        }
    }

    return $null
}

function Normalize-RepoPathValue($value) {
    if ($null -eq $value) {
        return ""
    }

    $normalized = $value.Trim([char[]]@([char]34, [char]39, [char]96, [char]32))
    $normalized = $normalized -replace "\*\*$", ""
    $normalized = $normalized -replace "\*$", ""
    return $normalized.Replace("\", "/").Trim("/")
}

function Test-PlaceholderValue($value) {
    if ($null -eq $value) {
        return $true
    }

    if ([string]::IsNullOrWhiteSpace($value)) {
        return $true
    }

    $normalized = $value.Trim()
    $badValues = @(
        "-",
        "TBD",
        "TODO",
        "Needs Confirmation",
        "N/A?",
        "<fill>",
        "<todo>"
    )

    if ($badValues -contains $normalized) {
        return $true
    }

    if ($normalized -match "^\[.*\]$") {
        return $true
    }

    return $false
}

function Assert-FieldFilled($path, $content, $label) {
    $value = Get-FieldValue $content $label
    if (Test-PlaceholderValue $value) {
        Fail "$path has empty or placeholder field: $label"
    }
}

function Assert-SectionHasConcreteBullet($path, $content, $heading) {
    $section = Get-Section $content $heading
    if ([string]::IsNullOrWhiteSpace($section)) {
        Fail "$path has empty section: ## $heading"
        return
    }

    $hasConcreteBullet = $false
    foreach ($line in ($section -split "`r?`n")) {
        $trimmed = $line.Trim()
        if ($trimmed -match "^- .+" -and $trimmed -ne "-") {
            $hasConcreteBullet = $true
            break
        }
    }

    if (-not $hasConcreteBullet) {
        Fail "$path needs at least one concrete bullet in section: ## $heading"
    }
}

function Get-SectionBullets($content, $heading) {
    $section = Get-Section $content $heading
    $items = New-Object System.Collections.Generic.List[string]

    foreach ($line in ($section -split "`r?`n")) {
        $trimmed = $line.Trim()
        if ($trimmed -match "^- (.+)$") {
            $items.Add($matches[1].Trim())
        }
    }

    return @($items)
}

function Assert-WorkspaceValue($path, $value) {
    $workspace = Normalize-RepoPathValue $value
    if (Test-PlaceholderValue $workspace) {
        Fail "$path has empty or placeholder active workspace"
        return ""
    }

    if (-not $workspace.StartsWith("workspaces/", [System.StringComparison]::OrdinalIgnoreCase)) {
        Fail "$path active workspace must be under workspaces/: $workspace"
        return $workspace
    }

    if ($workspace.Contains("..") -or [System.IO.Path]::IsPathRooted($workspace)) {
        Fail "$path active workspace must be repo-relative without traversal: $workspace"
        return $workspace
    }

    $workspacePath = Resolve-RepoPath $workspace
    if (-not (Test-Path -LiteralPath $workspacePath -PathType Container)) {
        Fail "$path active workspace does not exist: $workspace"
    }

    return $workspace
}

function Assert-WorkspaceProfileValue($path, $profileValue, $activeWorkspace) {
    $profilePath = Normalize-RepoPathValue $profileValue
    if (Test-PlaceholderValue $profilePath) {
        Fail "$path has empty or placeholder workspace profile"
        return
    }

    if (-not $profilePath.StartsWith("$activeWorkspace/", [System.StringComparison]::OrdinalIgnoreCase)) {
        Fail "$path workspace profile must be inside active workspace: $profilePath"
    }

    if (-not $profilePath.EndsWith("/.agent/profile.md", [System.StringComparison]::OrdinalIgnoreCase)) {
        Fail "$path workspace profile must end with .agent/profile.md: $profilePath"
    }

    $fullPath = Resolve-RepoPath $profilePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        Fail "$path workspace profile does not exist: $profilePath"
    }
}

function Assert-WorkspaceScopedBullets($path, $content, $heading, $activeWorkspace) {
    foreach ($item in (Get-SectionBullets $content $heading)) {
        $candidate = Normalize-RepoPathValue $item
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        if ($candidate.StartsWith("workspaces/", [System.StringComparison]::OrdinalIgnoreCase) -and
            -not $candidate.StartsWith("$activeWorkspace/", [System.StringComparison]::OrdinalIgnoreCase)) {
            Fail "$path $heading item points outside active workspace: $candidate"
        }
    }
}

function Assert-ReferencedPathsExist($path, $content, $activeWorkspace) {
    $matches = [regex]::Matches($content, '`([^`]+)`')
    foreach ($match in $matches) {
        $candidate = Normalize-RepoPathValue $match.Groups[1].Value
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        if ($candidate.Contains("*")) {
            continue
        }

        if (-not ($candidate.StartsWith("docs/", [System.StringComparison]::OrdinalIgnoreCase) -or
                $candidate.StartsWith("scripts/", [System.StringComparison]::OrdinalIgnoreCase) -or
                $candidate.StartsWith("$activeWorkspace/", [System.StringComparison]::OrdinalIgnoreCase) -or
                $candidate -eq "AGENTS.md")) {
            continue
        }

        $fullPath = Resolve-RepoPath $candidate
        if (-not (Test-Path -LiteralPath $fullPath)) {
            Fail "$path references missing path: $candidate"
        }
    }
}

function Assert-NoBlockingNeedsConfirmation($path, $content) {
    if ($AllowNeedsConfirmation) {
        return
    }

    $lineNumber = 0
    foreach ($line in ($content -split "`r?`n")) {
        $lineNumber += 1
        if ($line -match ":\s*Needs Confirmation\s*$") {
            Fail "$path has unresolved Needs Confirmation at line ${lineNumber}: $line"
        }
    }
}

function Test-TaskCard($path) {
    $file = Read-RepoFile $path
    $content = $file.Content
    if ([string]::IsNullOrWhiteSpace($content)) {
        return
    }

    $headings = @(
        "Activation",
        "Required Read Context",
        "Skill Selection",
        "Allowed Write Scope",
        "Read-Only Context",
        "Forbidden Paths",
        "Mission",
        "Dependencies And Unlocks",
        "System Token Usage",
        "Usage Evaluation",
        "Acceptance Criteria",
        "Ownership And Checkpoints",
        "Verification",
        "Stop Conditions",
        "Output Required"
    )

    foreach ($heading in $headings) {
        Assert-Heading $file.Path $content $heading
    }

    $fields = @(
        "Active workspace",
        "Workspace profile",
        "Task / Subtask",
        "Role",
        "Workflow mode",
        "Required skills",
        "Suggested skills",
        "Excluded skills",
        "Estimate",
        "Owned outcome",
        "Checkpoint interval",
        "Continue when",
        "Re-scope or stop when",
        "Escalation owner"
    )

    foreach ($field in $fields) {
        Assert-FieldFilled $file.Path $content $field
    }

    foreach ($heading in @("Allowed Write Scope", "Mission", "Acceptance Criteria", "Verification")) {
        Assert-SectionHasConcreteBullet $file.Path $content $heading
    }

    $activeWorkspace = Assert-WorkspaceValue $file.Path (Get-FieldValue $content "Active workspace")
    if (-not [string]::IsNullOrWhiteSpace($activeWorkspace)) {
        Assert-WorkspaceProfileValue $file.Path (Get-FieldValue $content "Workspace profile") $activeWorkspace
        Assert-WorkspaceScopedBullets $file.Path $content "Allowed Write Scope" $activeWorkspace
        Assert-WorkspaceScopedBullets $file.Path $content "Read-Only Context" $activeWorkspace
        Assert-ReferencedPathsExist $file.Path $content $activeWorkspace
    }

    Assert-NoBlockingNeedsConfirmation $file.Path $content
}

function Test-Checklist($path) {
    $file = Read-RepoFile $path
    $content = $file.Content
    if ([string]::IsNullOrWhiteSpace($content)) {
        return
    }

    $headings = @(
        "Metadata",
        "1) Full Delivery Fit",
        "2) Workspace Activation Gate",
        "3) Context Budget Gate",
        "4) System Token Usage Gate",
        "5) Dependency Graph Gate",
        "6) Domain Impact Map",
        "7) Contract Gate",
        "8) Ownership Gate",
        "9) Security Trigger Gate",
        "10) Verification Plan",
        "11) Sync Plan",
        "12) Start Decision",
        "13) Subagent Launch Notes"
    )

    foreach ($heading in $headings) {
        Assert-Heading $file.Path $content $heading
    }

    foreach ($field in @("Workflow mode", "Reason", "Orchestration shape", "Start approved", "Approved by", "Blocking items")) {
        Assert-FieldFilled $file.Path $content $field
    }

    $activeWorkspace = Assert-WorkspaceValue $file.Path (Get-FieldValue $content "Active workspace")
    if (-not [string]::IsNullOrWhiteSpace($activeWorkspace)) {
        Assert-WorkspaceProfileValue $file.Path (Get-FieldValue $content "Workspace profile") $activeWorkspace

        $contractLocation = Normalize-RepoPathValue (Get-FieldValue $content "Contract location")
        if (-not [string]::IsNullOrWhiteSpace($contractLocation)) {
            if (-not $contractLocation.StartsWith("$activeWorkspace/", [System.StringComparison]::OrdinalIgnoreCase)) {
                Fail "$($file.Path) contract location must be inside active workspace: $contractLocation"
            }
            $contractLocationPath = Resolve-RepoPath $contractLocation
            if (-not (Test-Path -LiteralPath $contractLocationPath -PathType Container)) {
                Fail "$($file.Path) contract location does not exist: $contractLocation"
            }
        }
    }

    $startApproved = Get-FieldValue $content "Start approved"
    $blockingItems = Get-FieldValue $content "Blocking items"

    if ($startApproved -match "^(?i)yes$" -and $blockingItems -notmatch "^(?i)(none|n/a|not applicable)$") {
        Fail "$($file.Path) cannot approve start with blocking items: $blockingItems"
    }

    if ($startApproved -match "^(?i)yes$" -and $content -notmatch '(?m)^-\s+\[x\]\s+No blocking `?Needs Confirmation`? items remain') {
        Fail "$($file.Path) must check 'No blocking Needs Confirmation items remain' before approval"
    }

    if ($StrictChecklist -and $content -match "(?m)^-\s+\[\s\]") {
        Fail "$($file.Path) contains unchecked checklist items in strict mode"
    }
}

function Test-Contract($path) {
    $file = Read-RepoFile $path
    $content = $file.Content
    if ([string]::IsNullOrWhiteSpace($content)) {
        return
    }

    foreach ($heading in @("Status", "Scope", "Parallel Start Minimum")) {
        Assert-Heading $file.Path $content $heading
    }

    $minimum = Get-Section $content "Parallel Start Minimum"
    if ([string]::IsNullOrWhiteSpace($minimum)) {
        Fail "$($file.Path) has empty Parallel Start Minimum section"
    }

    if (-not $AllowNeedsConfirmation -and $minimum.Contains("Needs Confirmation")) {
        Fail "$($file.Path) has unresolved Needs Confirmation in Parallel Start Minimum"
    }

    if (-not $AllowNeedsConfirmation -and $content -match "(?m)^###\s+Example Placeholder\s*$") {
        Fail "$($file.Path) still contains Example Placeholder"
    }

    if (-not $AllowNeedsConfirmation -and $content -match "(?m)^\s*-\s+[^:]+:\s*Needs Confirmation\s*$") {
        Fail "$($file.Path) still contains placeholder field values"
    }
}

if ([string]::IsNullOrWhiteSpace($TaskCardPath) -and [string]::IsNullOrWhiteSpace($ChecklistPath) -and $ContractPath.Count -eq 0) {
    $TaskCardPath = "docs/fixtures/dry-run/valid/SUBAGENT_TASK_CARD.filled.md"
    $ChecklistPath = "docs/fixtures/dry-run/valid/FULL_DELIVERY_START_CHECKLIST.filled.md"
    $ContractPath = @("workspaces/sample-app/.agent/contracts/API_CONTRACT.md")
}

if (-not [string]::IsNullOrWhiteSpace($TaskCardPath)) {
    Test-TaskCard $TaskCardPath
}

if (-not [string]::IsNullOrWhiteSpace($ChecklistPath)) {
    Test-Checklist $ChecklistPath
}

foreach ($contract in $ContractPath) {
    if (-not [string]::IsNullOrWhiteSpace($contract)) {
        Test-Contract $contract
    }
}

if ($failed) {
    Write-Host "Delivery readiness check failed." -ForegroundColor Red
    exit 1
}

Pass "delivery readiness"
