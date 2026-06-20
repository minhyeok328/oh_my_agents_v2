# Dry-run fixture

This fixture exercises the `secret_agents_v2` governance flow with a tracked sample app workspace.
Use it when changing rules, templates, validators, or onboarding copy and you want a quick system-level rehearsal.

## Model

- `profile.md is authoritative` for app-local execution context.
- `app-local AGENTS.md is optional`; do not create one for every generated app by default.
- The root `AGENTS.md` remains the operational source of truth.
- No real `.env`, credentials, local databases, or generated secrets are used in this fixture.
- The tracked sample profile lives at `workspaces/sample-app/.agent/profile.md`.
- The tracked sample manifest lives at `workspaces/sample-app/.agent/manifest.yml`.

## Simulated Activation

```text
Active workspace: workspaces/sample-app
Workspace profile: workspaces/sample-app/.agent/profile.md
Workspace manifest: workspaces/sample-app/.agent/manifest.yml
Contract location: workspaces/sample-app/.agent/contracts
Git target: shell | active app | none | Needs Confirmation
```

The sample workspace is a tracked fixture, not a production app.

## Checks

Run these from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-workspace-profile.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-workspace-manifest.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\classify-git-target.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-orchestration.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-contracts.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-delivery-readiness.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-delivery-readiness.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-docs.ps1
```

## Expected Review

- Workspace profile policy is readable without app-local `AGENTS.md`.
- Workspace manifest values match `profile.md`, active contract paths, and fixture verification commands.
- Contract files have a `Parallel Start Minimum`.
- Orchestration templates include dependency status, token usage, usage evaluation, and blocker handling.
- Filled readiness fixtures reject blank task cards, unresolved active contract placeholders, and unsafe start approvals.
- The readiness simulation also rejects cross-workspace write scopes and approved starts with unresolved blockers.
- Git target classification separates shell governance changes from app implementation changes.

Related docs:

- [Root README](../../../README.md)
- [Workspace guide](../../../workspaces/README.md)
- [Full delivery checklist](../../templates/FULL_DELIVERY_START_CHECKLIST.md)
