# Subagent Task Card

Use this compact card when launching an implementation subagent.
Do not paste full rule files unless the agent must act on them directly.
Follow `docs/agent-rules/subagent-execution.md` for launch gates, stop conditions, required output, and orchestrator integration.

## Activation

- Active workspace:
- Workspace profile:
- Task / Subtask:
- Role:
- Workflow mode:
- Hybrid node:

## Required Read Context

- `AGENTS.md`
- `docs/agent-rules/context-budget.md`
- `docs/agent-rules/hybrid-orchestration.md` when the task is a dependency node in hybrid work
- `docs/agent-rules/subagent-execution.md`
- docs/agent-rules/workspaces.md when app-scoped
- Workspace profile, when app-scoped:
- Spec/Subtask:
- Contracts:

## Skill Selection

- Required skills:
- Suggested skills:
- Excluded skills:
- Decision rule: Use any installed skill that clearly applies to this role and mission, unless it is excluded or would expand scope.

## Allowed Write Scope

-

## Read-Only Context

-

## Forbidden Paths

- `docs/**` unless explicitly assigned
- `workspaces/*` outside the active workspace
- `.git/**`
- real `.env`, `.env.local`, credentials, local databases, generated secrets
-

## Mission

-

## Dependencies And Unlocks

- Prerequisites:
- Starts when:
- Unlocks when complete:
- Blocking dependencies:

## System Token Usage

- Estimate: Low / Medium / High / exact count if available
- Main context drivers:
- Context intentionally omitted:

## Usage Evaluation

- Was the loaded context necessary for safety?
- Could any full document have been summarized instead?
- Did this delegation reduce risk, review cost, or coordination overhead enough to justify the context?
- Trim or keep next time:

## Acceptance Criteria

-

## Ownership And Checkpoints

- Owned outcome:
- Checkpoint interval:
- Continue when:
- Re-scope or stop when:
- Escalation owner:

## Verification

Run from the active workspace unless stated otherwise.

-

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
