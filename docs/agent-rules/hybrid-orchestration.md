# Hybrid Orchestration Rules

Use this file when Full Delivery work is large, cross-domain, dependency-heavy, or explicitly delegated across multiple agents.

Hybrid orchestration replaces the old "start every worker and wait for all of them" mental model.
Pure parallel work is still allowed, but only as a special case where nodes have no blocking dependencies between them.

## Core Model

Use a three-layer control structure:

```text
Root Orchestrator
-> Domain Orchestrator
-> Task Worker
```

The Root Orchestrator owns integration judgment.
Domain Orchestrators own execution flow inside their domains.
Task Workers own narrow outputs.

Do not add extra hierarchy unless a Program-level effort is too large for one Root Orchestrator to hold.
Do not use this hierarchy for small Default Workflow tasks that can be handled safely in the main session.

## Activation Fit

Use Hybrid Orchestration when at least one condition is true:

- the task crosses two or more domains such as backend, frontend, database, infrastructure, QA, or security
- a downstream task can start before every upstream domain finishes
- contract, migration, security, deployment, or verification dependencies affect execution order
- the user asks for end-to-end delivery, multi-agent delivery, subagents, delegation, or an Epic-level workflow
- context pressure would make a single root session hold too many implementation details

Do not use Hybrid Orchestration when:

- the task is a small Default Workflow question, edit, or focused fix
- one agent can safely complete the work with less coordination cost
- the dependency graph cannot be made explicit enough to review
- the user has not approved subagent/delegation use and the work can stay local

## Responsibility Boundaries

### Root Orchestrator

Owns:

- Epic goal, non-goals, scope, priority, and acceptance criteria
- domain impact map
- cross-domain contracts and interface approval
- dependency graph and wave sequencing
- risk and blocker triage
- activation or deactivation of Domain Orchestrators
- single user-facing reporting channel
- final integration and completion judgment

Does not own:

- every detailed implementation choice
- domain-local task ordering when it has no cross-domain impact
- worker micromanagement
- bypassing Domain Orchestrators to continuously direct individual workers

### Domain Orchestrator

Owns one domain's execution flow, such as backend, frontend, database, infrastructure, QA, or security.

Owns:

- domain-local task graph
- worker task cards inside the domain
- domain-local sequential versus parallel choices
- domain status reports to Root
- domain verification evidence
- escalation of contract drift, blockers, security triggers, and cross-domain impact

Does not own:

- changing cross-domain contracts without Root or Integration Coordinator approval
- broadening worker scope silently
- deciding final Epic completion
- editing outside the assigned domain

The Root may hold a Domain Orchestrator role inline for small or medium work.
Use a separate Domain Orchestrator subagent only when the domain has enough work to justify the added coordination layer.

### Task Worker

Owns one narrow outcome.

Owns:

- assigned files and folders
- assigned implementation or review output
- local verification
- compact return status

Must stop with `Needs Confirmation` when scope, contract behavior, security review, workspace, verification, or Git ownership is unclear.

## Dependency Graph

Represent work as dependency nodes rather than one flat parallel batch.

Each node should have:

- owner: Root, Domain Orchestrator, Task Worker, Review Agent, Security Review Agent, Integration Coordinator, or Git Steward
- domain: backend, database, frontend, infrastructure, QA, security, docs, integration, or mixed
- status: `Proposed`, `Ready`, `In Progress`, `Blocked`, `Needs Confirmation`, `Ready for Review`, `Done`
- dependencies: nodes, contracts, decisions, artifacts, or verification evidence required before starting
- unlocks: downstream nodes that may start when this node reaches `Done` or `Ready for Review`
- system token usage and evaluation: expected context cost, actual reported cost when available, and whether the cost was justified
- contract impact: none, read-only, update required, or Needs Confirmation
- security impact: none, triggered, reviewed, or Needs Confirmation
- verification: command, manual check, reviewer, or Needs Confirmation

Common dependency types:

- contract dependency: shared API, schema, UI/backend, infra, or config behavior
- artifact dependency: generated migration, component, endpoint, fixture, deployment config, or test harness
- verification dependency: lint, tests, build, smoke check, visual QA, security review, or integration review
- decision dependency: user decision, Root approval, scope cut, or tradeoff decision
- risk dependency: blocker, incident risk, irreversible migration, secret handling, or data exposure concern

## Waves

A wave is the current set of `Ready` nodes that can safely run now.

Hybrid orchestration does not wait for the entire wave when only one path is needed.
When a node finishes, the Root or relevant Domain Orchestrator checks its unlocks immediately.
Any newly `Ready` node may start before unrelated in-progress nodes finish.

Use these default waves for Epic work:

1. Epic framing: goal, scope, non-goals, acceptance, risk, domains.
2. Contract discovery: blocking contracts, architecture spikes, migration or security decisions.
3. Domain execution: ready domain-local work starts as soon as its dependencies are satisfied.
4. Rolling integration: review, QA, security, and integration checks start on completed slices.
5. Final convergence: unresolved blockers, full verification, handover, and completion judgment.

Pure parallel execution is allowed inside a wave only when:

- each node has a disjoint write scope
- shared contracts are already approved or marked not applicable
- no node depends on another in the same batch
- verification ownership is clear

## Checkpoint Reports

Use compact reports so the Root does not become a reporting bottleneck.

Domain Orchestrator report:

```md
- Status: In Progress | Blocked | Needs Confirmation | Ready for Review | Done
- Domain:
- Scope:
- Done:
- Active:
- Next ready nodes:
- Blocked nodes:
- Contract changes:
- Security impact:
- Verification:
- System token usage:
- Usage evaluation:
- Root decision needed:
```

Task Worker report:

```md
- Status: Completed | Blocked | Needs Confirmation
- Changed files:
- Summary:
- Verification:
- Contract impact:
- Security impact:
- System token usage:
- Usage evaluation:
- Unlocks:
- Follow-up required:
```

Root report to the user should summarize only:

- current wave
- completed decisions or outputs
- active domains
- blockers requiring user input
- next unlocked work
- verification status
- token usage and evaluation when it affected orchestration choices

## Integration Rules

Root must integrate returned work incrementally:

1. Check returned status.
2. Check changed files against assigned scope.
3. Check contract and security impact.
4. Mark downstream nodes `Ready` only when dependencies are actually satisfied.
5. Start newly ready work without waiting for unrelated nodes.
6. Run Review, Security Review, QA, or Integration Coordinator checks when required.
7. Keep unresolved `Needs Confirmation` items visible until resolved or explicitly descoped.

Subagent completion is evidence, not final approval.
Domain completion is evidence, not Epic completion.
The Root marks the Epic complete only after acceptance criteria, verification, scope control, and required reviews are satisfied.

## Stop Conditions

Stop and ask the user or escalate when:

- dependency order cannot be determined safely
- two domains need to edit the same files at the same time
- contract drift changes another domain's behavior
- a security trigger appears without a Security Review Agent path
- a worker needs access outside the workspace or assigned scope
- the same blocker, verification failure, or re-review loop repeats three times
- the hierarchy itself is adding more overhead than the task warrants
