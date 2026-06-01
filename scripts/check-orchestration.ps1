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

function Assert-Contains($path, $needle) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Fail "missing file: $path"
        return
    }

    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $path
    if (-not $content.Contains($needle)) {
        Fail "$path missing required orchestration text: $needle"
    }
}

function Assert-OrderedMarkers($path, $markers) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Fail "missing file: $path"
        return
    }

    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $path
    $lastIndex = -1
    foreach ($marker in $markers) {
        $index = $content.IndexOf($marker, [System.StringComparison]::Ordinal)
        if ($index -lt 0) {
            Fail "$path missing ordered marker: $marker"
            continue
        }
        if ($index -le $lastIndex) {
            Fail "$path marker out of order: $marker"
        }
        $lastIndex = $index
    }
}

Assert-OrderedMarkers "docs/templates/FULL_DELIVERY_START_CHECKLIST.md" @(
    "## 1) Full Delivery Fit",
    "## 2) Workspace Activation Gate",
    "## 3) Context Budget Gate",
    "## 4) System Token Usage Gate",
    "## 5) Dependency Graph Gate",
    "## 6) Domain Impact Map",
    "## 7) Contract Gate",
    "## 8) Ownership Gate",
    "## 9) Security Trigger Gate",
    "## 10) Verification Plan",
    "## 11) Sync Plan",
    "## 12) Start Decision",
    "## 13) Subagent Launch Notes"
)

$requiredTexts = @(
    @{ Path = "docs/templates/FULL_DELIVERY_START_CHECKLIST.md"; Text = "Root Orchestrator:" },
    @{ Path = "docs/templates/FULL_DELIVERY_START_CHECKLIST.md"; Text = 'No blocking `Needs Confirmation` items remain' },
    @{ Path = "docs/templates/FULL_DELIVERY_START_CHECKLIST.md"; Text = "System token usage plan:" },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = "Allowed status values:" },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = '`Proposed`' },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = '`Ready`' },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = '`In Progress`' },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = '`Blocked`' },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = '`Needs Confirmation`' },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = '`Ready for Review`' },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = '`Done`' },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = "## Usage And Evaluation" },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = "Root decision needed:" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "## Dependencies And Unlocks" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "## System Token Usage" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "## Usage Evaluation" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "Status: Completed | Blocked | Needs Confirmation" },
    @{ Path = "docs/coordination/AGENT_SYNC_CHECKLIST.md"; Text = "No private worker-to-worker assumptions remain" },
    @{ Path = "docs/templates/CROSS_AGENT_HANDOVER_TEMPLATE.md"; Text = "Routed via Orchestrator / Integration Coordinator" }
)

foreach ($check in $requiredTexts) {
    Assert-Contains $check.Path $check.Text
}

if ($failed) {
    Write-Host "Orchestration check failed." -ForegroundColor Red
    exit 1
}

Pass "orchestration structure"
