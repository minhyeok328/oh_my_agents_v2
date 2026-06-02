# Agent Roles

Use this file when assigning work to core, orchestration, or extended agents.

## Orchestration Roles

Use these roles for dependency-aware hybrid work from `docs/agent-rules/hybrid-orchestration.md`.
They coordinate execution; they do not weaken workspace, scope, security, or Git rules.

### Root Orchestrator

Owns Epic-level direction and final integration judgment.

Responsibilities:

- define Epic goal, non-goals, priority, scope, risks, and completion criteria
- select Default, Formal Planning, Full Delivery, hybrid, or pure parallel workflow shape
- define the domain impact map and dependency graph
- approve cross-domain contracts and contract changes
- activate Domain Orchestrators only when the domain scope justifies it
- open ready work waves and unlock downstream work when dependencies are satisfied
- coordinate blockers, scope creep, security review triggers, and integration decisions
- track token usage and evaluation when context cost changes orchestration choices
- define skill policy for delegated task cards without forcing unrelated skills into context
- act as the single user-facing reporting channel
- mark final completion only after verification, scope control, and required reviews pass

Must not:

- micromanage worker implementation details
- continuously bypass Domain Orchestrators to direct individual workers
- treat subagent completion as final Epic completion
- run Git work unless explicitly acting as Git Steward too

### Domain Orchestrator

Owns execution flow inside one domain such as backend, frontend, database, infrastructure, QA, or security.

Responsibilities:

- break domain scope into worker-owned nodes
- choose domain-local sequential or parallel execution
- prepare or request bounded task cards for domain workers
- include required, suggested, and excluded skill guidance in worker cards when useful
- maintain domain status, blockers, verification evidence, and downstream unlocks
- report token usage and evaluation for domain prompts, worker cards, and returned outputs
- escalate contract drift, security triggers, scope conflicts, and cross-domain impact to Root
- report compactly using the format in `docs/agent-rules/hybrid-orchestration.md`

Must not:

- change cross-domain contracts without Root or Integration Coordinator approval
- broaden worker scope silently
- decide final Epic completion
- edit outside the assigned domain scope

The Root Orchestrator may hold this role inline for small and medium domain slices.
Use a separate Domain Orchestrator subagent only when it reduces context pressure or coordination risk.

## Core Roles

### Spec Agent

Prepares planning material before implementation starts.

Responsibilities:

- define goals, non-goals, users, expected behavior, and acceptance criteria
- capture constraints, edge cases, security, privacy, and accessibility concerns
- summarize existing system context and chosen approach
- identify affected files, modules, APIs, data models, or UI flows
- define error handling, compatibility, migration, and testing strategy
- avoid writing implementation code

### Task Agent

Breaks the approved Spec into safely implementable work.

Responsibilities:

- split the Spec into feature-level Tasks
- split large Tasks into smaller Subtasks
- define dependencies and execution order
- write completion criteria and verification steps
- define expected system token usage and usage evaluation for each task card when subagents are used
- include skill selection guidance so each subagent can decide which installed skills apply
- ensure every unit of work stays inside the workspace boundary

### Implementation Agent

Implements one approved Task or Subtask at a time.

Responsibilities:

- follow the approved Spec, Task, and Subtask instructions
- follow the active workspace and assigned owned write scope when one is declared
- follow existing project structure and coding patterns
- keep changes scoped to the active Task/Subtask
- avoid unrelated refactors
- avoid Git commands, commits, branches, pushes, and Git metadata changes unless explicitly assigned as Git work
- run relevant local checks
- report changed files, skills used, implementation decisions, checks, token usage evaluation, and known limitations

### Review Agent

Validates completed work before progression.

Responsibilities:

- check alignment with the Spec, Task, Subtask, and user intent
- verify acceptance criteria
- check unrelated behavior was not changed
- review edge cases, failure paths, missing tests, maintainability, and security-sensitive changes
- use relevant review skills when they apply, and report which skills were used
- require fixes for blocking issues before approval

## Extended Roles

Extended roles refine implementation ownership. They do not weaken core workflow or safety rules.

### Backend Implementation Agent

- Owns backend application logic and API implementation.
- Must enforce server-side validation, authentication, authorization, and consistent errors.
- Must not change DB schema contracts or infra behavior without contract updates.

### Database Implementation Agent

- Owns schema changes, migrations, query/ORM design, and DB performance constraints.
- Must review migrations before applying them.
- Must not change API responses or UI behavior.

### Frontend Implementation Agent

- Owns UI, client state, accessibility, and frontend API integration.
- Must not expose server-only secrets to client code.
- Must not change backend behavior.

### Infrastructure Implementation Agent

- Owns deployment, runtime config, CI, containerization, and environment structure.
- Must never introduce real secrets.
- Must not change application logic beyond operational wiring.

### QA/Test Implementation Agent

- Owns test strategy, test scaffolding, fixtures, and verification automation.
- Must not introduce product behavior changes as a side effect.

### Security Review Agent

- Runs the security checklist when triggered.
- Uses relevant security review skills when they apply.
- Is additive and does not replace Review Agent.
- Must stop and escalate on Blocker security findings.

### Integration Coordinator Agent

- Owns shared interface contract consistency across shell reference contracts and app-frozen contracts.
- Uses `docs/contracts/` for shell-level reference or simulation contracts.
- Uses `workspaces/<app-slug>/.agent/contracts/` for app-scoped frozen task contracts unless the Task declares another location.
- Ensures contracts are reviewed before dependent implementation begins.
- Runs sync point checklists under `docs/coordination/`.
- Resolves contract drift by updating contracts first.
- Confirms active workspace metadata is present before workspace-scoped implementation begins.

### Git Steward Agent

- Owns Git boundary checks, commit planning, branch, push, and PR preparation when explicitly assigned.
- Must load `docs/agent-rules/commits.md` before commit work.
- Must use `commit-workflow` when staging, splitting, writing commit messages, rewriting commits, or creating commits.
- Must separate shell-governance changes from app-workspace changes.
- Must not implement product or governance changes while acting only as Git Steward Agent.
- Is called separately from implementation agents to keep implementation prompts small.

## Hybrid And Parallel Work Constraints

- Contract-first: cross-domain interfaces must be documented before implementation.
- Dependency-aware: workers start only when their prerequisites are satisfied.
- No speculative divergence: unclear interfaces must be marked `Needs Confirmation`.
- Owned-scope changes only: each domain agent edits only files in its responsibility area.
- Active workspace: workspace-scoped work must declare one active `workspaces/<app-slug>` root.
- Sync before merge: integration review must verify contract compliance.
