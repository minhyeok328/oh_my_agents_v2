# Hybrid Workflow (Dependency-Driven)

This document defines how multiple domain agents can work sequentially, in parallel, or in mixed waves **without** weakening root `AGENTS.md` rules.
The file name is kept for compatibility with existing references; the operating model is now hybrid orchestration.

## Definition

Hybrid work is **not** "simultaneous ad-hoc coding".
Hybrid work means:

- **Contract-first**: shared interfaces are documented and approved first.
- **Dependency-aware execution**: work starts only when its prerequisites are satisfied.
- **Independent implementation**: each domain agent implements only within its scope.
- **Rolling unlocks**: downstream work may start as soon as its dependencies are satisfied.
- **Sync points**: integration is validated at scheduled checkpoints with explicit checklists.

## Preconditions (Hard Gates)

Dependent implementation may start only when:

- Workspace-scoped implementation declares:
  - one active `workspaces/<app-slug>` root
  - a workspace profile path or `Needs Confirmation`
  - allowed write scopes and forbidden paths for every implementation agent
- Subagent launch rules are selected:
  - `docs/agent-rules/subagent-execution.md`
- Relevant contract docs exist and are reviewed:
  - shell-level reference or simulation contracts: `docs/contracts/*`
  - app-scoped frozen contracts: `workspaces/<app-slug>/.agent/contracts/*`
- A dependency graph exists:
  - each node has an owner, status, prerequisites, unlocks, and verification path
  - first-wave nodes are marked `Ready`
  - blocked nodes are marked `Blocked` or `Needs Confirmation`
- A token usage and evaluation plan exists:
  - each Root, Domain Orchestrator, worker, review, security, integration, and Git prompt has an expected system token usage estimate
  - exact usage counts are recorded when available; otherwise Low/Medium/High estimates are used
  - High-usage prompts name the safety, contract, security, or integration reason
- Subtasks are decomposed so that:
  - each Subtask maps to exactly one domain agent as primary owner
  - cross-domain changes are expressed as contract updates + separate owned subtasks
- A sync checklist is selected:
  - `docs/coordination/AGENT_SYNC_CHECKLIST.md`
- "Parallel Start Minimum" sections in relevant contract docs are filled and frozen for the active Task.

For app-scoped work, prefer freezing task-specific contracts in the active app workspace.
`docs/contracts/` remains the shell-level reference and simulation contract set unless the Task explicitly declares it as the active contract location.

## Roles in Hybrid Mode

- Root Orchestrator:
  - owns Epic scope, dependency graph, wave sequencing, blocker routing, and final completion judgment
- Domain Orchestrators:
  - own domain-local task graphs and worker launch decisions
- Integration Coordinator Agent:
  - owns contract updates, drift resolution, sync facilitation
- Domain Implementation Agents:
  - implement their own subtasks only
- Review Agent:
  - validates correctness, intent alignment, scope control
- Security Review Agent:
  - runs security checklist when triggered by scope (auth, tokens, inputs, files, deps, config)

## Workflow

### Phase 0: Epic Frame And Dependency Graph

- Root Orchestrator confirms goal, non-goals, acceptance criteria, risk, domains, and first dependency graph.
- Decide which Domain Orchestrators are separate agents and which are held inline by Root.
- Mark nodes `Proposed`, `Ready`, `Blocked`, or `Needs Confirmation`.
- Do not launch a worker for a node that is not `Ready`.

### Phase 1: Contract Draft

- Confirm active workspace metadata when work targets an app under `workspaces/`.
- Select the active contract location before drafting.
- Update contract(s) first.
- Mark unknowns as **Needs Confirmation** (do not guess).

### Phase 2: Contract Review

- Review Agent approves contract change.
- Security Review Agent is required when:
  - auth/session/token/cookie changes
  - user input validation rules
  - file upload/download
  - dependency or infra config changes

### Phase 3: Domain Decomposition

Task Agent or Domain Orchestrators decompose work so each ready node can proceed safely.
Each Subtask must include active workspace, owned write scope, forbidden paths, dependency prerequisites, downstream unlocks, verification commands, and Git steward status when workspace-scoped.
The orchestrator prepares a bounded task card for each subagent before launch.

### Phase 4: Ready-Node Implementation

- Each domain agent implements one Subtask at a time.
- Each domain agent owns the assigned Subtask outcome until it returns `Completed`, `Blocked`, or `Needs Confirmation`.
- Each domain agent edits only inside the active workspace and assigned owned scope.
- Domain implementation agents do not run Git commands or modify Git metadata.
- Domain agents return the required status and output fields from `docs/agent-rules/subagent-execution.md`.
- Domain agents return system token usage and evaluation notes with their status.
- Checkpoints are used to decide whether to continue, add context, narrow scope, or escalate; they are not forced timeouts when meaningful progress is visible.
- When a node completes, Root or the relevant Domain Orchestrator checks downstream unlocks immediately.
- Newly ready nodes may start without waiting for unrelated in-progress nodes.
- If a Subtask requires changing a shared interface:
  - stop implementation
  - update contract first
  - re-decompose if needed

Pure parallel execution is allowed only when all launched nodes are already `Ready`, have disjoint write scopes, and do not depend on each other.

### Phase 5: Rolling Sync Point

Integration Coordinator runs:

- Subagent output scope check
- Ownership and checkpoint status check
- Dependency graph status check
- Token usage and evaluation check
- Contract compliance check
- Integration review template
- Required verification commands (project-defined; otherwise Needs Confirmation)

### Phase 6: Handover

Follow root `AGENTS.md` handover rules for Task completion and next-task Subtasks sheet when requested or when durable coordination is required.

## Deadlock Escape Conditions

Stop and escalate to the user if:

- Fix & re-review loops repeat 3 times without convergence
- Verification step fails 3 consecutive times
- Checkpoints repeatedly show no meaningful progress on the owned outcome
- Scope becomes ambiguous or requires workspace boundary breach
- A real secret appears at risk of being read/created/committed
