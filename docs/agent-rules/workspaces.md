# Workspace Activation Rules

Use this file when `secret_agents_v2` is acting as the governance control plane for one or more user Git projects under `workspaces/`.

## Model

`secret_agents_v2` is the governance control plane.
Product implementation happens inside exactly one active app workspace for a Task.

Active workspace format:

```text
workspaces/<app-slug>
```

Examples:

```text
workspaces/my-app
workspaces/admin-dashboard
```

## Activation Requirement

Any app-scoped implementation that changes product files must have a clear active workspace before files are changed.
For Full Delivery Workflow, record the full Task metadata:

```md
Active workspace:
Workspace profile:
Contract location:
Allowed write scope:
Forbidden paths:
Verification:
Git steward:
```

If the active workspace is missing or ambiguous, stop and ask for clarification before implementation.

## Workspace Naming

- Use lowercase slugs.
- Prefer letters, numbers, and hyphens.
- Do not use spaces.
- Do not use `..`, absolute paths, home-relative paths, or drive-root paths.
- Keep the active workspace under `workspaces/`.

## Read And Write Boundaries

Agents may read:

- root `AGENTS.md`
- needed files under `docs/agent-rules/`
- assigned Specs, contracts, templates, and coordination docs
- files inside the active workspace needed for the Task

Agents may write:

- only files required by the approved Task
- only inside the active workspace unless the Task explicitly assigns shell-governance changes
- only inside the subagent's assigned owned scope when acting as an Implementation Agent

Agents must not read or modify:

- other `workspaces/*` apps
- paths outside the project workspace
- `.git` internals unless the user explicitly asks for Git inspection
- real `.env`, `.env.local`, credentials, local databases, generated secrets, or large unmanaged artifacts

## Governance Docs

Root governance files are normally read-only for app implementation:

- `AGENTS.md`
- `docs/agent-rules/**`
- `docs/templates/**`
- `docs/coordination/**`

Edit governance docs only when the Task is explicitly about shell policy, templates, onboarding, or coordination.

## Workspace Profile

Each active app should provide a profile at:

```text
workspaces/<app-slug>/.agent/profile.md
```

The profile freezes app-local execution context:

- app name and active root
- package manager and install command
- lint, test, build, and manual verification commands
- environment example path with dummy values only
- allowed implementation roots
- app-local forbidden paths
- app-local contract location
- minimal Git mode pointer for a future Git steward

Use `docs/templates/WORKSPACE_PROFILE.template.md` when creating a profile.

## Contract Location

Use this default split:

- shell-level reference or simulation contracts: `docs/contracts/`
- shell-owned reusable templates: `docs/templates/`
- app-specific frozen contracts: `workspaces/<app-slug>/.agent/contracts/`

The active Task may choose a different contract location, but it must declare that path in Task metadata.
For app-scoped work, prefer freezing task-specific contracts under the active app's `.agent/contracts/` directory.
The Integration Coordinator owns contract consistency, not a single storage location.

## Subagent Scope

Every implementation subagent must receive:

- active workspace
- assigned role
- owned write scope
- explicit out-of-scope paths
- owned outcome and checkpoint expectations
- verification commands
- stop conditions

Use `docs/templates/SUBAGENT_TASK_CARD.template.md` to launch small, scoped subagents.

## Git Boundary

Workspace activation does not define commit, branch, push, or PR behavior.

Implementation agents must not run Git commands or modify Git metadata.
When Git work is needed, assign it separately and load the commit rules then.

Task metadata may include only a short pointer:

```md
Git steward: required before commit | not required | Needs Confirmation
```

## Stop Conditions

Stop and ask for confirmation when:

- the active workspace is missing or points outside `workspaces/`
- the Task appears to require changes in multiple app workspaces
- owned scopes overlap between subagents
- implementation requires governance-doc changes that were not assigned
- implementation requires Git actions that were not assigned
- app verification commands are missing and cannot be inferred safely
