# Dry-run fixture

This fixture exercises the `secret_agents_v2` governance flow without creating a real app workspace.
Use it when changing rules, templates, validators, or onboarding copy and you want a quick system-level rehearsal.

## Model

- `profile.md is authoritative` for app-local execution context.
- `app-local AGENTS.md is optional`; do not create one for every generated app by default.
- The root `AGENTS.md` remains the operational source of truth.
- No real `.env`, credentials, local databases, or generated secrets are used in this fixture.

## Simulated Activation

```text
Active workspace: workspaces/demo-app
Workspace profile: workspaces/demo-app/.agent/profile.md
Contract location: workspaces/demo-app/.agent/contracts
Git target: shell | active app | none | Needs Confirmation
```

The paths above are simulated. Do not create them for this dry run unless a separate task explicitly asks for an app fixture.

## Checks

Run these from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-workspace-profile.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\classify-git-target.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-orchestration.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-contracts.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-docs.ps1
```

## Expected Review

- Workspace profile policy is readable without app-local `AGENTS.md`.
- Contract files have a `Parallel Start Minimum`.
- Orchestration templates include dependency status, token usage, usage evaluation, and blocker handling.
- Git target classification separates shell governance changes from app implementation changes.

Related docs:

- [Root README](../../../README.md)
- [Workspace guide](../../../workspaces/README.md)
- [Full delivery checklist](../../templates/FULL_DELIVERY_START_CHECKLIST.md)
