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

function Test-RequiredFile($path) {
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        return
    }
    Fail "missing required file: $path"
}

function Test-ForbiddenFile($path) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        return
    }
    Fail "stale non-v2 artifact must be removed: $path"
}

function Test-Contains($path, $needle) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Fail "cannot check missing file: $path"
        return
    }

    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $path
    if ($content.Contains($needle)) {
        return
    }
    Fail "$path missing required text: $needle"
}

function Get-TrackedMarkdownFiles {
    $status = git ls-files "*.md"
    if ($LASTEXITCODE -ne 0) {
        Fail "git ls-files failed"
        return @()
    }
    return @($status)
}

function Test-TrailingWhitespace($files) {
    foreach ($file in $files) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            continue
        }

        $lineNumber = 0
        foreach ($line in Get-Content -Encoding UTF8 -LiteralPath $file) {
            $lineNumber += 1
            if ($line -match "[ \t]+$") {
                Fail "trailing whitespace: ${file}:${lineNumber}"
            }
        }
    }
}

function Test-MarkdownLinks($files) {
    $linkPattern = [regex]'\[[^\]]+\]\(([^)]+)\)'

    foreach ($file in $files) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            continue
        }

        $baseDir = Split-Path -Parent $file
        if ([string]::IsNullOrWhiteSpace($baseDir)) {
            $baseDir = "."
        }

        $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $file
        foreach ($match in $linkPattern.Matches($content)) {
            $target = $match.Groups[1].Value.Trim()
            if ([string]::IsNullOrWhiteSpace($target)) {
                continue
            }
            if ($target.StartsWith("#")) {
                continue
            }
            if ($target -match "^[a-zA-Z][a-zA-Z0-9+.-]*:") {
                continue
            }

            $targetPath = ($target -split "#", 2)[0].Trim("<>")
            if ([string]::IsNullOrWhiteSpace($targetPath)) {
                continue
            }

            $resolvedTarget = Join-Path $baseDir $targetPath
            if (-not (Test-Path -LiteralPath $resolvedTarget)) {
                Fail "broken markdown link: ${file} -> ${target}"
            }
        }
    }
}

function Test-SecretLikeValues {
    $trackedFiles = git ls-files
    if ($LASTEXITCODE -ne 0) {
        Fail "git ls-files failed during secret-like value scan"
        return
    }

    $filesToScan = @(
        $trackedFiles +
        $requiredFiles
    ) | Sort-Object -Unique

    $patterns = @(
        @{ Name = "OpenAI-style API key"; Regex = "sk-[A-Za-z0-9]{20,}" },
        @{ Name = "GitHub personal access token"; Regex = "ghp_[A-Za-z0-9]{20,}" },
        @{ Name = "AWS access key"; Regex = "AKIA[0-9A-Z]{16}" },
        @{ Name = "Slack token"; Regex = "xox[baprs]-[A-Za-z0-9-]{20,}" },
        @{ Name = "Private key block"; Regex = "-----BEGIN (RSA|OPENSSH|PRIVATE) KEY-----" }
    )

    foreach ($file in $filesToScan) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            continue
        }

        $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $file
        foreach ($pattern in $patterns) {
            if ($content -match $pattern.Regex) {
                Fail "secret-like value detected (${pattern.Name}): $file"
            }
        }
    }
}

function Test-RealEnvFilesNotTracked {
    $trackedFiles = git ls-files
    if ($LASTEXITCODE -ne 0) {
        Fail "git ls-files failed during env tracking scan"
        return
    }

    foreach ($file in $trackedFiles) {
        $name = Split-Path -Leaf $file
        if ($name -like ".env*" -and $name -ne ".env.example") {
            Fail "real env file must not be tracked: $file"
        }
    }
}

function Invoke-ProjectCheck($scriptPath) {
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        Fail "missing project check script: $scriptPath"
        return
    }

    & powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath
    if ($LASTEXITCODE -ne 0) {
        Fail "project check failed: $scriptPath"
        return
    }

    Pass "project check: $scriptPath"
}

$requiredFiles = @(
    ".github/workflows/docs-check.yml",
    "AGENTS.md",
    "README.md",
    "docs/onboarding/USER_GUIDE.ko.md",
    "docs/onboarding/examples/LOGIN_SUBAGENT_FLOW.ko.md",
    "docs/agent-rules/workflow.md",
    "docs/agent-rules/hybrid-orchestration.md",
    "docs/agent-rules/roles.md",
    "docs/agent-rules/context-budget.md",
    "docs/agent-rules/subagent-execution.md",
    "docs/agent-rules/workspaces.md",
    "docs/agent-rules/commits.md",
    "docs/skills/commit-workflow/SKILL.md",
    "docs/templates/SUBAGENT_TASK_CARD.template.md",
    "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md",
    "docs/templates/WORKSPACE_PROFILE.template.md",
    "docs/templates/FULL_DELIVERY_START_CHECKLIST.md",
    "docs/coordination/PARALLEL_WORKFLOW.md",
    "docs/coordination/AGENT_SYNC_CHECKLIST.md",
    "docs/contracts/API_CONTRACT.md",
    "docs/contracts/DB_SCHEMA_CONTRACT.md",
    "docs/contracts/FRONTEND_BACKEND_CONTRACT.md",
    "docs/contracts/INFRA_DEPLOYMENT_CONTRACT.md",
    "docs/fixtures/dry-run/README.md",
    "scripts/classify-git-target.ps1",
    "scripts/check-contracts.ps1",
    "scripts/check-workspace-profile.ps1",
    "scripts/check-orchestration.ps1",
    "scripts/install-commit-workflow.ps1",
    "workspaces/README.md"
)

foreach ($file in $requiredFiles) {
    Test-RequiredFile $file
}
if (-not $failed) {
    Pass "required files"
}

$forbiddenFiles = @(
    "docs/reports/TASK1_COMPLETION.md",
    "docs/specs/TASK2_SUBTASKS.md",
    "docs/specs/TASK3_IMPLEMENTATION_AGENTS_RESTRUCTURE.md",
    "docs/templates/IMPLEMENTATION_AGENT_TEMPLATE.md"
)

foreach ($file in $forbiddenFiles) {
    Test-ForbiddenFile $file
}
if (-not $failed) {
    Pass "no stale non-v2 artifacts"
}

$requiredTextChecks = @(
    @{ Path = ".github/workflows/docs-check.yml"; Text = "powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-docs.ps1" },
    @{ Path = ".github/workflows/docs-check.yml"; Text = "git diff --check" },
    @{ Path = ".github/workflows/docs-check.yml"; Text = "fetch-depth: 0" },
    @{ Path = ".github/workflows/docs-check.yml"; Text = "github.event_name" },
    @{ Path = "README.md"; Text = "# secret_agents_v2" },
    @{ Path = "README.md"; Text = "v2 difference" },
    @{ Path = "README.md"; Text = "governance control plane" },
    @{ Path = "README.md"; Text = "profile.md is authoritative" },
    @{ Path = "README.md"; Text = "Markdown links" },
    @{ Path = "README.md"; Text = "secret-like values" },
    @{ Path = "README.md"; Text = "docs/onboarding/USER_GUIDE.ko.md" },
    @{ Path = "README.md"; Text = "docs/agent-rules/hybrid-orchestration.md" },
    @{ Path = "README.md"; Text = "workspaces/README.md" },
    @{ Path = "README.md"; Text = "spawn_agent" },
    @{ Path = "README.md"; Text = "docs/skills/commit-workflow/SKILL.md" },
    @{ Path = "README.md"; Text = "install-commit-workflow.ps1" },
    @{ Path = "README.md"; Text = "classify-git-target.ps1" },
    @{ Path = "README.md"; Text = "check-orchestration.ps1" },
    @{ Path = "README.md"; Text = "check-contracts.ps1" },
    @{ Path = "README.md"; Text = "DOMAIN_ORCHESTRATOR_CARD.template.md" },
    @{ Path = "AGENTS.md"; Text = "docs/agent-rules/context-budget.md" },
    @{ Path = "AGENTS.md"; Text = "docs/agent-rules/hybrid-orchestration.md" },
    @{ Path = "AGENTS.md"; Text = "docs/agent-rules/subagent-execution.md" },
    @{ Path = "AGENTS.md"; Text = "docs/agent-rules/workspaces.md" },
    @{ Path = "AGENTS.md"; Text = "commit-workflow" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "subagent-execution.md" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "# secret_agents_v2" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "v2 difference" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "Markdown links" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "secret-like values" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "hybrid-orchestration.md" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "System token usage" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "docs/onboarding/examples/LOGIN_SUBAGENT_FLOW.ko.md" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "Git target: shell | active app | none | Needs Confirmation" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "classify-git-target.ps1" },
    @{ Path = "docs/onboarding/examples/LOGIN_SUBAGENT_FLOW.ko.md"; Text = "spawn_agent" },
    @{ Path = "docs/onboarding/examples/LOGIN_SUBAGENT_FLOW.ko.md"; Text = "Subagent Task Card" },
    @{ Path = "docs/onboarding/examples/LOGIN_SUBAGENT_FLOW.ko.md"; Text = "Git Steward Handoff" },
    @{ Path = "docs/agent-rules/context-budget.md"; Text = "docs/agent-rules/subagent-execution.md" },
    @{ Path = "docs/agent-rules/context-budget.md"; Text = "docs/agent-rules/hybrid-orchestration.md" },
    @{ Path = "docs/agent-rules/context-budget.md"; Text = "System Token Usage" },
    @{ Path = "docs/agent-rules/context-budget.md"; Text = "Usage Evaluation" },
    @{ Path = "docs/agent-rules/hybrid-orchestration.md"; Text = "Root Orchestrator" },
    @{ Path = "docs/agent-rules/hybrid-orchestration.md"; Text = "Domain Orchestrator" },
    @{ Path = "docs/agent-rules/hybrid-orchestration.md"; Text = "Task Worker" },
    @{ Path = "docs/agent-rules/hybrid-orchestration.md"; Text = "dependency nodes" },
    @{ Path = "docs/agent-rules/hybrid-orchestration.md"; Text = "system token usage and evaluation" },
    @{ Path = "docs/agent-rules/roles.md"; Text = "Root Orchestrator" },
    @{ Path = "docs/agent-rules/roles.md"; Text = "Domain Orchestrator" },
    @{ Path = "docs/agent-rules/roles.md"; Text = "token usage and evaluation" },
    @{ Path = "docs/agent-rules/workspaces.md"; Text = "workspaces/<app-slug>" },
    @{ Path = "docs/agent-rules/workspaces.md"; Text = "workspaces/<app-slug>/.agent/profile.md" },
    @{ Path = "docs/agent-rules/workspaces.md"; Text = "shell-level reference or simulation contracts" },
    @{ Path = "docs/agent-rules/workspaces.md"; Text = "app-specific frozen contracts" },
    @{ Path = "docs/agent-rules/templates.md"; Text = "Do not create folder-level AGENTS.md files by default." },
    @{ Path = "docs/agent-rules/templates.md"; Text = "app-local AGENTS.md is optional" },
    @{ Path = "docs/agent-rules/subagent-execution.md"; Text = "Subagents do not choose their own workspace" },
    @{ Path = "docs/agent-rules/subagent-execution.md"; Text = "Subagents are opt-in execution resources" },
    @{ Path = "docs/agent-rules/subagent-execution.md"; Text = "dependency node" },
    @{ Path = "docs/agent-rules/subagent-execution.md"; Text = "Delegation Policy" },
    @{ Path = "docs/agent-rules/subagent-execution.md"; Text = "Cross-Agent Communication" },
    @{ Path = "docs/agent-rules/subagent-execution.md"; Text = "Cross-agent information must flow through the orchestrator" },
    @{ Path = "docs/agent-rules/subagent-execution.md"; Text = "spawn_agent" },
    @{ Path = "docs/agent-rules/subagent-execution.md"; Text = "Status: Completed | Blocked | Needs Confirmation" },
    @{ Path = "docs/agent-rules/subagent-execution.md"; Text = "Integration After Return" },
    @{ Path = "docs/agent-rules/subagent-execution.md"; Text = "System token usage" },
    @{ Path = "docs/agent-rules/subagent-execution.md"; Text = "Usage evaluation" },
    @{ Path = "docs/agent-rules/commits.md"; Text = "commit-workflow" },
    @{ Path = "docs/agent-rules/commits.md"; Text = "docs/skills/commit-workflow/SKILL.md" },
    @{ Path = "docs/agent-rules/commits.md"; Text = "Git target" },
    @{ Path = "docs/agent-rules/commits.md"; Text = "Pre-Stage Classification" },
    @{ Path = "docs/agent-rules/commits.md"; Text = "Git Steward Stop Conditions" },
    @{ Path = "docs/templates/WORKSPACE_PROFILE.template.md"; Text = "## Git Pointer" },
    @{ Path = "docs/templates/WORKSPACE_PROFILE.template.md"; Text = "profile.md is authoritative" },
    @{ Path = "docs/templates/WORKSPACE_PROFILE.template.md"; Text = "app-local AGENTS.md is optional" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "Active workspace:" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "docs/agent-rules/workspaces.md when app-scoped" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "Workspace profile, when app-scoped:" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "## Allowed Write Scope" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "## Dependencies And Unlocks" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "## System Token Usage" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "## Usage Evaluation" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "## Forbidden Paths" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "Status: Completed | Blocked | Needs Confirmation" },
    @{ Path = "docs/templates/SUBAGENT_TASK_CARD.template.md"; Text = "Git steward required" },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = "Domain Orchestrator" },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = "Dependency Nodes" },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = "Usage And Evaluation" },
    @{ Path = "docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md"; Text = "Root decision needed" },
    @{ Path = "docs/templates/SUBAGENT_PROMPTS.md"; Text = "## Domain Orchestrator" },
    @{ Path = "docs/templates/SUBAGENT_PROMPTS.md"; Text = "Hybrid orchestration rules" },
    @{ Path = "docs/templates/SUBAGENT_PROMPTS.md"; Text = "Token usage and evaluation" },
    @{ Path = "docs/templates/FULL_DELIVERY_START_CHECKLIST.md"; Text = "Workspace Activation Gate" },
    @{ Path = "docs/templates/FULL_DELIVERY_START_CHECKLIST.md"; Text = "Root Orchestrator:" },
    @{ Path = "docs/templates/FULL_DELIVERY_START_CHECKLIST.md"; Text = "## 4) System Token Usage Gate" },
    @{ Path = "docs/templates/FULL_DELIVERY_START_CHECKLIST.md"; Text = "## 5) Dependency Graph Gate" },
    @{ Path = "docs/templates/FULL_DELIVERY_START_CHECKLIST.md"; Text = "Context Budget Gate" },
    @{ Path = "docs/templates/FULL_DELIVERY_START_CHECKLIST.md"; Text = "System Token Usage Gate" },
    @{ Path = "docs/templates/FULL_DELIVERY_START_CHECKLIST.md"; Text = "subagent-execution.md" },
    @{ Path = "docs/skills/commit-workflow/SKILL.md"; Text = "name: commit-workflow" },
    @{ Path = "docs/skills/commit-workflow/SKILL.md"; Text = "type(scope): summary" },
    @{ Path = "scripts/install-commit-workflow.ps1"; Text = "docs/skills/commit-workflow/SKILL.md" },
    @{ Path = "docs/coordination/PARALLEL_WORKFLOW.md"; Text = "docs/agent-rules/subagent-execution.md" },
    @{ Path = "docs/coordination/PARALLEL_WORKFLOW.md"; Text = "Hybrid Workflow" },
    @{ Path = "docs/coordination/PARALLEL_WORKFLOW.md"; Text = "Rolling unlocks" },
    @{ Path = "docs/coordination/PARALLEL_WORKFLOW.md"; Text = "token usage and evaluation" },
    @{ Path = "docs/coordination/PARALLEL_WORKFLOW.md"; Text = "when requested or when durable coordination is required" },
    @{ Path = "docs/coordination/PARALLEL_WORKFLOW.md"; Text = "shell-level reference or simulation contracts" },
    @{ Path = "docs/coordination/PARALLEL_WORKFLOW.md"; Text = "workspaces/<app-slug>/.agent/contracts" },
    @{ Path = "docs/coordination/AGENT_SYNC_CHECKLIST.md"; Text = "Status: Completed" },
    @{ Path = "docs/coordination/AGENT_SYNC_CHECKLIST.md"; Text = "Dependency Graph Status" },
    @{ Path = "docs/coordination/AGENT_SYNC_CHECKLIST.md"; Text = "Token Usage And Evaluation" },
    @{ Path = "docs/coordination/AGENT_SYNC_CHECKLIST.md"; Text = "Cross-Agent Sync" },
    @{ Path = "docs/coordination/AGENT_SYNC_CHECKLIST.md"; Text = "No private worker-to-worker assumptions remain" },
    @{ Path = "docs/coordination/RISK_REGISTER.md"; Text = "R-007: System token usage drift" },
    @{ Path = "docs/coordination/RISK_REGISTER.md"; Text = "R-008: Validation blind spots" },
    @{ Path = "docs/templates/CROSS_AGENT_HANDOVER_TEMPLATE.md"; Text = "Routed via Orchestrator / Integration Coordinator" },
    @{ Path = "docs/templates/CROSS_AGENT_HANDOVER_TEMPLATE.md"; Text = "Token usage notes" },
    @{ Path = "docs/templates/INTEGRATION_REVIEW_TEMPLATE.md"; Text = "Token usage and evaluation" },
    @{ Path = "docs/onboarding/examples/LOGIN_SUBAGENT_FLOW.ko.md"; Text = "CROSS_AGENT_COMMUNICATION" },
    @{ Path = "docs/contracts/API_CONTRACT.md"; Text = "Scope note: this file is a shell-level reference or simulation contract." },
    @{ Path = "docs/contracts/DB_SCHEMA_CONTRACT.md"; Text = "Scope note: this file is a shell-level reference or simulation contract." },
    @{ Path = "docs/contracts/FRONTEND_BACKEND_CONTRACT.md"; Text = "Scope note: this file is a shell-level reference or simulation contract." },
    @{ Path = "docs/contracts/INFRA_DEPLOYMENT_CONTRACT.md"; Text = "Scope note: this file is a shell-level reference or simulation contract." },
    @{ Path = "docs/contracts/INFRA_DEPLOYMENT_CONTRACT.md"; Text = "## Parallel Start Minimum" },
    @{ Path = "docs/fixtures/dry-run/README.md"; Text = "Dry-run fixture" },
    @{ Path = "docs/fixtures/dry-run/README.md"; Text = "profile.md is authoritative" },
    @{ Path = "docs/fixtures/dry-run/README.md"; Text = "app-local AGENTS.md is optional" },
    @{ Path = "docs/fixtures/dry-run/README.md"; Text = "Git target: shell | active app | none | Needs Confirmation" },
    @{ Path = "docs/fixtures/dry-run/README.md"; Text = "check-orchestration.ps1" },
    @{ Path = "docs/fixtures/dry-run/README.md"; Text = "check-contracts.ps1" },
    @{ Path = "workspaces/README.md"; Text = "Active workspace: workspaces/<app-slug>" },
    @{ Path = "workspaces/README.md"; Text = "secret_agents_v2" },
    @{ Path = "workspaces/README.md"; Text = "profile.md is authoritative" },
    @{ Path = "workspaces/README.md"; Text = "app-local AGENTS.md is optional" },
    @{ Path = "docs/onboarding/examples/LOGIN_SUBAGENT_FLOW.ko.md"; Text = "secret_agents_v2" },
    @{ Path = "workspaces/README.md"; Text = ".agent/profile.md" },
    @{ Path = "workspaces/README.md"; Text = "commit-workflow" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "profile.md is authoritative" },
    @{ Path = "docs/onboarding/USER_GUIDE.ko.md"; Text = "app-local AGENTS.md is optional" },
    @{ Path = "scripts/check-docs.ps1"; Text = 'Invoke-ProjectCheck ".\scripts\check-workspace-profile.ps1"' },
    @{ Path = "scripts/check-docs.ps1"; Text = 'Invoke-ProjectCheck ".\scripts\classify-git-target.ps1"' },
    @{ Path = "scripts/check-docs.ps1"; Text = 'Invoke-ProjectCheck ".\scripts\check-orchestration.ps1"' },
    @{ Path = "scripts/check-docs.ps1"; Text = 'Invoke-ProjectCheck ".\scripts\check-contracts.ps1"' }
)

foreach ($check in $requiredTextChecks) {
    Test-Contains $check.Path $check.Text
}
if (-not $failed) {
    Pass "required references and fields"
}

Invoke-ProjectCheck ".\scripts\check-workspace-profile.ps1"
Invoke-ProjectCheck ".\scripts\classify-git-target.ps1"
Invoke-ProjectCheck ".\scripts\check-orchestration.ps1"
Invoke-ProjectCheck ".\scripts\check-contracts.ps1"

$markdownFiles = @(
    (Get-TrackedMarkdownFiles) +
    ($requiredFiles | Where-Object { $_ -like "*.md" })
) | Sort-Object -Unique
Test-MarkdownLinks $markdownFiles
if (-not $failed) {
    Pass "markdown links resolve"
}
Test-RealEnvFilesNotTracked
if (-not $failed) {
    Pass "real env files are not tracked"
}
Test-SecretLikeValues
if (-not $failed) {
    Pass "no secret-like values"
}
Test-TrailingWhitespace $markdownFiles
if (-not $failed) {
    Pass "no trailing whitespace in tracked markdown"
}

if ($failed) {
    Write-Host "Docs check failed." -ForegroundColor Red
    exit 1
}

Write-Host "Docs check passed."
