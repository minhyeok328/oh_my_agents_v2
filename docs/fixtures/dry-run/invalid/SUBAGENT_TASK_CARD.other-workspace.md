# Subagent Task Card

## Activation

- Active workspace: workspaces/sample-app
- Workspace profile: workspaces/sample-app/.agent/profile.md
- Task / Subtask: Invalid cross-workspace fixture
- Role: Backend Implementation Agent
- Workflow mode: Default Workflow
- Hybrid node: not applicable

## Required Read Context

- `AGENTS.md`
- `workspaces/sample-app/.agent/profile.md`

## Skill Selection

- Required skills: none
- Suggested skills: code-review
- Excluded skills: commit-workflow
- Decision rule: Use any installed skill that clearly applies to this role and mission, unless it is excluded or would expand scope.

## Allowed Write Scope

- `workspaces/other-app/src/**`

## Read-Only Context

- `workspaces/sample-app/.agent/contracts/API_CONTRACT.md`

## Forbidden Paths

- `docs/**`
- `workspaces/*` outside `workspaces/sample-app`
- `.git/**`
- real `.env`, `.env.local`, credentials, local databases, generated secrets

## Mission

- Demonstrate that cross-workspace write scope is rejected.

## Dependencies And Unlocks

- Prerequisites: active API contract approved
- Starts when: task card is approved
- Unlocks when complete: none
- Blocking dependencies: none

## System Token Usage

- Estimate: Low
- Main context drivers: invalid fixture
- Context intentionally omitted: unrelated docs

## Usage Evaluation

- Was the loaded context necessary for safety? yes
- Could any full document have been summarized instead? no
- Did this delegation reduce risk, review cost, or coordination overhead enough to justify the context? yes
- Trim or keep next time: keep as negative fixture

## Acceptance Criteria

- Readiness check rejects the task card.

## Ownership And Checkpoints

- Owned outcome: rejected invalid fixture
- Checkpoint interval: immediate
- Continue when: not applicable
- Re-scope or stop when: always
- Escalation owner: Root Orchestrator

## Verification

- Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-delivery-readiness.ps1`

## Stop Conditions

Stop and report if:

- the active workspace is ambiguous
- the change requires files outside allowed write scope
- the change requires contract updates not assigned to this subtask
- the change triggers security review but no Security Review Agent is assigned
- the change requires Git commands or Git metadata changes
- verification commands are missing or unsafe to infer

## Output Required

- Status: Completed | Blocked | Needs Confirmation
- Changed files:
- Summary:
- Skills used:
- Verification:
- Contract impact:
- Security impact:
- Unlocks:
- System token usage:
- Usage evaluation:
- Assumptions:
- Follow-up required:
  - Git steward required: yes/no/Needs Confirmation
  - Suggested commit target: shell/active app/none/Needs Confirmation
