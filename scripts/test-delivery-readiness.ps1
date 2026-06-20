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

function Invoke-ReadinessCase($name, $arguments, $expectedExitCode) {
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\check-delivery-readiness.ps1" @arguments 2>&1
    $ErrorActionPreference = $previousErrorActionPreference
    $actualExitCode = $LASTEXITCODE

    if ($actualExitCode -ne $expectedExitCode) {
        Fail "$name expected exit $expectedExitCode but got $actualExitCode"
        foreach ($line in $output) {
            Write-Host $line
        }
        return
    }

    Pass "$name"
}

Invoke-ReadinessCase "valid readiness fixture" @() 0
Invoke-ReadinessCase "blank task card rejected" @("-TaskCardPath", "docs\templates\SUBAGENT_TASK_CARD.template.md") 1
Invoke-ReadinessCase "reference contract placeholder rejected" @("-ContractPath", "docs\contracts\API_CONTRACT.md") 1
Invoke-ReadinessCase "cross-workspace task card rejected" @("-TaskCardPath", "docs\fixtures\dry-run\invalid\SUBAGENT_TASK_CARD.other-workspace.md") 1
Invoke-ReadinessCase "blocked checklist approval rejected" @("-ChecklistPath", "docs\fixtures\dry-run\invalid\FULL_DELIVERY_START_CHECKLIST.blocked.md") 1

if ($failed) {
    Write-Host "Delivery readiness simulation failed." -ForegroundColor Red
    exit 1
}

Write-Host "Delivery readiness simulation passed."
