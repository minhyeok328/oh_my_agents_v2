param(
    [switch]$StrictTaskContract
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

$failed = $false

function Pass($message) {
    Write-Host "[ok] $message"
}

function Warn($message) {
    Write-Host "[warn] $message" -ForegroundColor Yellow
}

function Fail($message) {
    Write-Host "[fail] $message" -ForegroundColor Red
    $script:failed = $true
}

function Assert-Contains($path, $content, $needle) {
    if (-not $content.Contains($needle)) {
        Fail "$path missing required contract text: $needle"
    }
}

function Get-Section($content, $heading) {
    $start = $content.IndexOf($heading, [System.StringComparison]::Ordinal)
    if ($start -lt 0) {
        return ""
    }

    $sectionStart = $start + $heading.Length
    $tail = $content.Substring($sectionStart)
    $nextHeading = [regex]::Match($tail, "(?m)^## ")
    if ($nextHeading.Success) {
        return $tail.Substring(0, $nextHeading.Index)
    }

    return $tail
}

$contracts = @(
    "docs/contracts/API_CONTRACT.md",
    "docs/contracts/DB_SCHEMA_CONTRACT.md",
    "docs/contracts/FRONTEND_BACKEND_CONTRACT.md",
    "docs/contracts/INFRA_DEPLOYMENT_CONTRACT.md"
)

foreach ($contract in $contracts) {
    if (-not (Test-Path -LiteralPath $contract -PathType Leaf)) {
        Fail "missing contract: $contract"
        continue
    }

    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $contract
    Assert-Contains $contract $content "Scope note: this file is a shell-level reference or simulation contract."
    Assert-Contains $contract $content "## Status"
    Assert-Contains $contract $content "## Scope"
    Assert-Contains $contract $content "## Parallel Start Minimum"

    $minimum = Get-Section $content "## Parallel Start Minimum"
    if ([string]::IsNullOrWhiteSpace($minimum)) {
        Fail "$contract has an empty Parallel Start Minimum section"
    }

    if ($StrictTaskContract -and $minimum.Contains("Needs Confirmation")) {
        Fail "$contract has blocking Needs Confirmation inside Parallel Start Minimum"
    }
    elseif ($minimum.Contains("Needs Confirmation")) {
        Warn "$contract keeps Needs Confirmation inside reference Parallel Start Minimum"
    }
}

if ($failed) {
    Write-Host "Contract check failed." -ForegroundColor Red
    exit 1
}

Pass "contracts"
