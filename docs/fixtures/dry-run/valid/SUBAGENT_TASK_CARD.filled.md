# Subagent Task Card

## Activation

- Active workspace: workspaces/sample-app
- Workspace profile: workspaces/sample-app/.agent/profile.md
- Task / Subtask: Fixture task for delivery readiness validation
- Role: Backend Implementation Agent
- Workflow mode: Default Workflow
- Hybrid node: not applicable

## Required Read Context

- `AGENTS.md`
- `docs/agent-rules/workspaces.md`
- `workspaces/sample-app/.agent/profile.md`
- `workspaces/sample-app/.agent/contracts/API_CONTRACT.md`

## Skill Selection

- Required skills: none
- Suggested skills: code-review
- Excluded skills: commit-workflow
- Decision rule: Use any installed skill that clearly applies to this role and mission, unless it is excluded or would expand scope.

## Allowed Write Scope

- `workspaces/sample-app/src/api/**`
- `workspaces/sample-app/tests/api/**`

## Read-Only Context

- `workspaces/sample-app/.agent/contracts/API_CONTRACT.md`
- `workspaces/sample-app/package.json`

## Forbidden Paths

- `docs/**`
- `workspaces/*` outside `workspaces/sample-app`
- `.git/**`
- real `.env`, `.env.local`, credentials, local databases, generated secrets

## Mission

- Implement the fixture API behavior described by the active API contract.

## Dependencies And Unlocks

- Prerequisites: active API contract approved
- Starts when: task card is approved
- Unlocks when complete: API review fixture
- Blocking dependencies: none

## System Token Usage

- Estimate: Low
- Main context drivers: task card, workspace profile, and active API contract
- Context intentionally omitted: unrelated governance docs and app history

## Usage Evaluation

- Was the loaded context necessary for safety? yes
- Could any full document have been summarized instead? no
- Did this delegation reduce risk, review cost, or coordination overhead enough to justify the context? yes
- Trim or keep next time: keep this compact task card shape

## Acceptance Criteria

- API fixture behavior matches the active contract.
- Tests for the fixture endpoint pass.

## Ownership And Checkpoints

- Owned outcome: API fixture implementation and matching tests
- Checkpoint interval: after implementation before verification
- Continue when: files stay inside the allowed write scope
- Re-scope or stop when: contract or workspace scope changes
- Escalation owner: Root Orchestrator

## Verification

- Run `npm.cmd test`

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
