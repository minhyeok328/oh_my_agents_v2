# Workflow Rules

Use this file only when the user asks for Formal Planning Workflow, Full Delivery Workflow, Spec or Task/Subtask creation, handoff, hybrid or parallel multi-agent work, or an existing numbered Task sequence.

Ordinary questions, analysis, small edits, focused fixes, and routine implementation slices should stay in the Default Workflow from `AGENTS.md`.
Bounded subagent or delegation requests can stay in Default Workflow unless they also require formal planning, hybrid orchestration, or parallel multi-agent delivery.

## Workflow Selection

Default Workflow is the normal path.
It does not require Spec, Task/Subtask, Review Agent, or handover artifacts unless the user explicitly asks for them.

Full Delivery Workflow is opt-in.
Use it when the user explicitly asks the agent to own the work from initial planning through Spec writing and development, or when the user asks for end-to-end delivery, hybrid orchestration, or parallel multi-agent delivery.

Formal Planning Workflow is also opt-in.
Use it when the user asks for a Spec, design, implementation plan, Task/Subtask breakdown, handoff, or other planning artifact without asking the agent to implement the work.

A request for a Spec, implementation plan, handoff, or bounded subagent/delegation by itself does not switch the task into Full Delivery Workflow.

If Formal Planning or Full Delivery appears necessary for safety but the user did not request it, explain why and ask before switching into it.

## Default Workflow

1. Inspect only the context needed to answer or implement safely.
2. Answer, implement, or report findings directly.
3. Keep edits focused on the approved request.
4. Run relevant verification.
5. Self-review for scope, correctness, and workspace safety.
6. Report changed files, verification results, assumptions, and residual risks.

No formal Spec, Task document, Review Agent, or handover artifact is required.

## Formal Planning Workflow

1. Clarify only what is needed to make the requested planning artifact accurate.
2. Inspect relevant project context.
3. Write or update the requested Spec, plan, Task/Subtask breakdown, or handoff.
4. Check the artifact for scope, contradictions, missing acceptance criteria, and verification gaps.
5. Verify links, paths, and document consistency when applicable.
6. Report the artifact path, assumptions, and any decisions that require user approval before implementation.

Do not implement product changes unless the user explicitly approves moving into implementation.

## Full Delivery Workflow

1. Clarify goals, non-goals, constraints, acceptance criteria, and verification.
2. Write or update a Spec before implementation.
3. Review the Spec for scope, clarity, contradictions, missing requirements, and security concerns.
4. Break the work into Tasks and Subtasks when useful.
5. Confirm active workspace metadata for app-scoped implementation.
6. Use `docs/agent-rules/hybrid-orchestration.md` when the work is cross-domain, dependency-heavy, delegated, or Epic-sized.
7. Build a dependency-aware execution graph before launching domain work.
8. Implement one ready Subtask at a time, or launch independent ready Subtasks in parallel when their scopes and contracts do not overlap.
9. Review completed Subtasks and unlock downstream work as soon as dependencies are satisfied.
10. Run Security Review Agent checks when a security trigger applies.
11. Fix issues and re-review when needed.
12. Run explicit verification.
13. Produce a concise completion report or handover when requested or when the work is part of an existing formal sequence.

## Spec Format

Use this format when a Spec is needed:

```md
## Summary
## Goals
## Non-Goals
## User Flow
## Requirements
## Acceptance Criteria
## Constraints
## Risks
## Task Breakdown
## Verification
## Security Review
```

For a very small formal request, the Spec may omit sections that are not relevant, but it must still make scope, acceptance criteria, and verification explicit.

## Task Format

Use this format when a Task/Subtask document is needed:

```md
### Task: [short English title]

- Purpose: Explain why this work is needed.
- Scope: Describe what this work may change and what is out of scope.
- Dependencies: List work that must be completed first.
- Acceptance Criteria: Define specific conditions that prove completion.
- Verification: List tests, builds, lint checks, or manual checks to run.
```

## Handover Artifacts

Create handover artifacts only when the user requested formal task tracking, when subagents or hybrid/parallel work need durable coordination, or when the work is part of an existing numbered Task sequence.

Default paths for numbered formal work:

- `docs/reports/TASK[number]_COMPLETION.md`
- `docs/specs/TASK[next-number]_SUBTASKS.md`

Completion report should include:

- completion timestamp
- responsible agent or role
- Spec alignment checklist
- changed files and implementation summary
- test and verification results
- items requiring user confirmation

Next-task instruction sheet should include:

- previous Task report and base branch
- atomic Subtasks in execution order
- target files, local rules, acceptance criteria, and verification commands
- deadlock escape conditions

## Startup Rule

When starting from an existing numbered Task, read the relevant `docs/specs/TASK[number]_SUBTASKS.md` first and summarize the first Subtask's purpose and target files to the user.

For Default Workflow work that is not part of an existing numbered Task sequence, a short scope note is sufficient.

## Active Workspace Metadata

When `secret_agents` is used as a shell for an app under `workspaces/`, Full Delivery app implementation must include:

```md
Active workspace:
Workspace profile:
Contract location:
Allowed write scope:
Forbidden paths:
Verification:
Git steward:
```

Use `docs/agent-rules/workspaces.md` for workspace activation rules, `docs/agent-rules/context-budget.md` for compact subagent context loading, and `docs/agent-rules/subagent-execution.md` for subagent launch and integration rules.

## Hybrid Full Delivery

Use dependency-aware hybrid orchestration for approved cross-domain or multi-agent work.
Pure parallel work is allowed only when the active nodes have no blocking dependencies between them.

1. Root Orchestrator frames the Epic goal, scope, acceptance criteria, domains, risks, and initial dependency graph.
2. Integration Coordinator drafts or updates relevant contracts under `docs/contracts/` or the active app's `.agent/contracts/`.
3. Contracts are reviewed before dependent implementation begins.
4. Task Agent or Domain Orchestrators decompose work into domain-owned nodes with explicit dependencies and unlocks.
5. Root Orchestrator opens the first wave of ready nodes.
6. Domain Orchestrators manage domain-local sequential or parallel worker execution.
7. Domain agents implement only inside their owned scope.
8. The orchestrator integrates returned output and checks scope, verification, stop conditions, and downstream unlocks.
9. Newly ready downstream work may start immediately without waiting for unrelated in-progress nodes.
10. Integration Coordinator runs sync checks under `docs/coordination/`.
11. Review Agent validates correctness and scope.
12. Security Review Agent runs when triggered.
13. Final verification and handover are produced.

Dependent implementation must not begin until relevant contracts are drafted and reviewed.
