# Full Delivery Hybrid Start Checklist

Use this checklist before starting any Full Delivery hybrid or parallel multi-agent work.
Dependent implementation may begin only after every required gate is answered and any blocking `Needs Confirmation` item is resolved.

## Metadata

- Task / Spec:
- Date/time:
- Root Orchestrator:
- Integration Coordinator Agent:
- Requested outcome:
- Source request:
- Active workspace:
- Workspace profile:
- Related docs:
  - `AGENTS.md`
  - `docs/agent-rules/context-budget.md`
  - `docs/agent-rules/subagent-execution.md`
  - `docs/agent-rules/workspaces.md`
  - `docs/agent-rules/workflow.md`
  - `docs/agent-rules/roles.md`
  - `docs/agent-rules/hybrid-orchestration.md`
  - `docs/coordination/PARALLEL_WORKFLOW.md`

## 1) Full Delivery Fit

- [ ] The user explicitly requested Full Delivery Workflow, end-to-end delivery, hybrid orchestration, or parallel multi-agent delivery.
- [ ] The work is large enough, cross-domain enough, dependency-heavy enough, or parallel enough to justify formal coordination.
- [ ] The expected work can be split into independently owned Subtasks.
- [ ] The user request and acceptance target are understood.

Decision:

- Workflow mode: Full Delivery Workflow
- Reason:
- Why Default Workflow is not enough:
- Orchestration shape: Hybrid / Pure parallel / Sequential with Domain Orchestrator / Needs Confirmation

## 2) Workspace Activation Gate

Complete this gate when implementation targets an app under `workspaces/`.

- [ ] Active workspace is declared as `workspaces/<app-slug>`.
- [ ] Workspace profile exists or is marked `Needs Confirmation`.
- [ ] Only one active workspace is in scope for this task.
- [ ] Other `workspaces/*` apps are out of scope.
- [ ] Governance docs are read-only unless this task explicitly assigns policy/template changes.
- [ ] Implementation agents will not run Git commands or modify Git metadata.
- [ ] Git Steward will use `docs/agent-rules/commits.md` and `commit-workflow` when commit work is required.

Workspace status:

| Field | Value | Notes |
| --- | --- | --- |
| Active workspace |  |  |
| Workspace profile |  |  |
| Contract location |  |  |
| Allowed write roots |  |  |
| Forbidden paths |  |  |
| Git steward | Required before commit / Not required / Needs Confirmation |  |
| Git target | shell / active app / none / Needs Confirmation |  |

## 3) Context Budget Gate

- [ ] User explicitly requested subagents, delegation, hybrid orchestration, or parallel agent work before any Superpowers `spawn_agent` call.
- [ ] Default Workflow automatic delegation is not being used.
- [ ] Orchestrator has selected the immediate local critical-path task.
- [ ] Delegated subtasks are non-overlapping and can run when their dependency prerequisites are satisfied.
- [ ] Subagents will receive compact task cards with owned outcomes and checkpoint expectations instead of full planning packets.
- [ ] Domain Orchestrators will receive `docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md` when a separate domain orchestration layer is used.
- [ ] Required rule files are selected by role.
- [ ] Hybrid orchestration rules are selected when dependency-aware waves apply: `docs/agent-rules/hybrid-orchestration.md`.
- [ ] Subagent launch and integration rules are selected: `docs/agent-rules/subagent-execution.md`.
- [ ] Security checklist is loaded only if a security trigger applies.
- [ ] Commit rules are loaded only for explicit Git work.
- [ ] Large Specs or contracts are summarized unless full detail is required.

Context notes:

- Subagent card template:
- Domain Orchestrator card template:
- Full docs required:
- Summaries prepared:

## 4) System Token Usage Gate

- [ ] Expected system token usage is recorded for Root, each Domain Orchestrator, and each worker prompt.
- [ ] Exact counts will be used when available; otherwise each prompt is estimated as Low, Medium, or High.
- [ ] High-usage prompts have a reason tied to safety, contracts, security, or integration risk.
- [ ] Each delegated task card includes context intentionally omitted.
- [ ] Usage evaluation will be collected from every returning subagent, reviewer, and orchestrator.
- [ ] The final handover will state what context should be trimmed or kept next time.

System token usage plan:

| Role / Node | Estimate | Main Context Drivers | Context Omitted | Evaluation Owner |
| --- | --- | --- | --- | --- |
|  | Low / Medium / High / exact |  |  |  |

## 5) Dependency Graph Gate

Hybrid work must identify ready work and blocking dependencies before implementation starts.
Pure parallel work may mark all nodes in the first wave as independent.

- [ ] Root Orchestrator is assigned.
- [ ] Domain Orchestrators are assigned or explicitly held inline by Root.
- [ ] Dependency nodes are listed with owners, statuses, prerequisites, unlocks, and verification.
- [ ] Nodes that can start now are marked `Ready`.
- [ ] Nodes blocked by contracts, security review, workspace profile, verification, or user decisions are marked `Blocked` or `Needs Confirmation`.
- [ ] The first wave does not require waiting for unrelated domains to finish before downstream ready work can start.

Dependency graph:

| Node | Domain | Owner | Status | Prerequisites | Unlocks | Verification |
| --- | --- | --- | --- | --- | --- | --- |
|  |  |  | Proposed |  |  |  |

## 6) Domain Impact Map

Mark every domain touched by the task.

- [ ] Backend application logic / APIs
- [ ] Database schema / migrations / queries
- [ ] Frontend UI / client state / API integration
- [ ] Infrastructure / CI / deployment / runtime config
- [ ] QA / tests / fixtures / verification automation
- [ ] Documentation / specs / reports only
- [ ] Security-sensitive behavior

Notes:

- Primary domains:
- Secondary domains:
- Out of scope:

## 7) Contract Gate

Dependent implementation must not begin until all relevant shared contracts are drafted, reviewed, and frozen for the active task.

- [ ] `docs/contracts/API_CONTRACT.md` reviewed or marked not applicable.
- [ ] `docs/contracts/DB_SCHEMA_CONTRACT.md` reviewed or marked not applicable.
- [ ] `docs/contracts/FRONTEND_BACKEND_CONTRACT.md` reviewed or marked not applicable.
- [ ] `docs/contracts/INFRA_DEPLOYMENT_CONTRACT.md` reviewed or marked not applicable.
- [ ] Every relevant contract has a filled "Parallel Start Minimum" section.
- [ ] Contract unknowns are marked `Needs Confirmation`.
- [ ] No domain agent is expected to guess shared interface behavior.
- [ ] Review Agent has approved the relevant contract set.

Contract status:

| Contract | Applies? | Status | Reviewer | Notes |
| --- | --- | --- | --- | --- |
| `API_CONTRACT.md` | Yes/No | Draft/Approved/Needs Confirmation |  |  |
| `DB_SCHEMA_CONTRACT.md` | Yes/No | Draft/Approved/Needs Confirmation |  |  |
| `FRONTEND_BACKEND_CONTRACT.md` | Yes/No | Draft/Approved/Needs Confirmation |  |  |
| `INFRA_DEPLOYMENT_CONTRACT.md` | Yes/No | Draft/Approved/Needs Confirmation |  |  |

## 8) Ownership Gate

Each Subtask must have exactly one primary implementation owner.

- [ ] Each Subtask has one primary domain owner.
- [ ] Owned files/folders are explicitly listed for each Subtask.
- [ ] Owned outcome and checkpoint expectations are explicitly listed for each delegated Subtask.
- [ ] Out-of-scope files/folders are explicitly listed for each Subtask.
- [ ] Cross-domain changes are represented as contract updates plus separate owned Subtasks.
- [ ] No Subtask requires two agents to edit the same file at the same time.
- [ ] Handover path is clear for dependent Subtasks.

Ownership map:

| Subtask | Primary Agent | Owned Outcome | Owned Files/Folders | Explicitly Out of Scope | Checkpoint Expectations | Dependencies |
| --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |

## 9) Security Trigger Gate

If any item is checked, load `docs/agent-rules/security-review.md` and assign Security Review Agent.

- [ ] Authentication, sessions, cookies, tokens, passwords, or redirects
- [ ] Authorization, roles, ownership, admin behavior, or resource access
- [ ] User input from body, query, params, headers, forms, files, or external APIs
- [ ] Database schemas, migrations, queries, data storage, or sensitive data
- [ ] File upload, download, paths, generated files, or public file access
- [ ] External APIs, webhooks, network calls, dependencies, or configuration
- [ ] Logging, analytics, monitoring, environment variables, or secrets
- [ ] No security trigger applies

Security decision:

- Security Review Agent required: Yes/No
- Reason:
- Security checklist location:

## 10) Verification Plan

Define verification before implementation starts.

- [ ] Lint command identified or marked not applicable.
- [ ] Unit test command identified or marked not applicable.
- [ ] Integration test command identified or marked not applicable.
- [ ] Build command identified or marked not applicable.
- [ ] Manual verification steps identified when automated checks are insufficient.
- [ ] Contract-critical verification is assigned to a responsible agent.

Verification commands:

| Check | Command | Owner | Required? | Notes |
| --- | --- | --- | --- | --- |
| Lint |  |  | Yes/No |  |
| Unit tests |  |  | Yes/No |  |
| Integration tests |  |  | Yes/No |  |
| Build |  |  | Yes/No |  |
| Manual checks |  |  | Yes/No |  |

## 11) Sync Plan

- [ ] Sync checklist selected: `docs/coordination/AGENT_SYNC_CHECKLIST.md`
- [ ] Integration review template selected: `docs/templates/INTEGRATION_REVIEW_TEMPLATE.md`
- [ ] Orchestrator integration step selected: `docs/agent-rules/subagent-execution.md` section 9.
- [ ] Hybrid unlock rule is understood: newly ready downstream nodes may start without waiting for unrelated in-progress nodes.
- [ ] Sync points are defined before implementation starts.
- [ ] Drift handling rule is understood: update contracts first, then adjust Subtasks.
- [ ] Deadlock escape conditions are understood.

Sync points:

| Sync Point | Trigger | Participants | Required Evidence |
| --- | --- | --- | --- |
| Contract approval | Before implementation | Integration Coordinator, Review Agent, Security Review Agent if required | Approved contract notes |
| Subagent return check | After each subagent returns | Orchestrator, relevant reviewer if needed | Status, changed files, verification, scope check, ownership/checkpoint check |
| Dependency unlock check | After a node finishes | Root or relevant Domain Orchestrator | Updated ready/blocked node status |
| Token usage review | After each orchestration wave | Root, Domain Orchestrators, Integration Coordinator | Usage estimate, actual count if available, evaluation, trim/keep notes |
| Midpoint sync | After first domain Subtask completes | Relevant domain agents, Integration Coordinator | Handover + verification status |
| Integration review | Before final handover | Integration Coordinator, Review Agent, Security Review Agent if required | Integration review output |

## 12) Start Decision

Ready-node implementation may start only if there are no blocking `Needs Confirmation` items for that node.

- [ ] Full Delivery fit confirmed.
- [ ] Workspace activation confirmed or marked not applicable.
- [ ] Context budget gate confirmed.
- [ ] System token usage gate confirmed.
- [ ] Dependency graph gate confirmed.
- [ ] Relevant contracts approved.
- [ ] Ownership map complete.
- [ ] Security review requirement decided.
- [ ] Verification plan complete.
- [ ] Sync plan complete.
- [ ] No blocking `Needs Confirmation` items remain.

Decision:

- Start approved: Yes/No
- Approved by:
- Conditions:
- Blocking items:

## 13) Subagent Launch Notes

Use `docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md` for separate Domain Orchestrator launches.
Use `docs/templates/SUBAGENT_TASK_CARD.template.md` for compact implementation launches and `docs/templates/SUBAGENT_PROMPTS.md` when full role prompts are required.
Use `docs/agent-rules/subagent-execution.md` for launch gates, stop conditions, required output, and orchestrator integration.

Launch order:

1. Root Orchestrator confirms the dependency graph and first ready wave.
2. Integration Coordinator Agent confirms contracts and ownership.
3. Task Agent or Domain Orchestrators finalize Subtasks if they are not already final.
4. Domain Orchestrators begin only ready domain nodes.
5. Domain Implementation Agents begin only approved owned Subtasks.
6. Review Agent reviews each completed Subtask.
7. Security Review Agent reviews triggered security-sensitive work.
8. Root or relevant Domain Orchestrator unlocks downstream nodes as soon as dependencies are satisfied.
9. Integration Coordinator runs sync and final integration review.

Per-agent launch list:

| Agent | Prompt Template | Subtask | May Start? | Notes |
| --- | --- | --- | --- | --- |
| Root Orchestrator | `FULL_DELIVERY_START_CHECKLIST.md` |  | Yes/No |  |
| Backend Domain Orchestrator | `DOMAIN_ORCHESTRATOR_CARD.template.md` |  | Yes/No |  |
| Frontend Domain Orchestrator | `DOMAIN_ORCHESTRATOR_CARD.template.md` |  | Yes/No |  |
| Infrastructure Domain Orchestrator | `DOMAIN_ORCHESTRATOR_CARD.template.md` |  | Yes/No |  |
| QA/Security Domain Orchestrator | `DOMAIN_ORCHESTRATOR_CARD.template.md` |  | Yes/No |  |
| Integration Coordinator Agent | `SUBAGENT_PROMPTS.md` |  | Yes/No |  |
| Task Agent | `SUBAGENT_PROMPTS.md` |  | Yes/No |  |
| Backend Implementation Agent | `SUBAGENT_PROMPTS.md` |  | Yes/No |  |
| Database Implementation Agent | `SUBAGENT_PROMPTS.md` |  | Yes/No |  |
| Frontend Implementation Agent | `SUBAGENT_PROMPTS.md` |  | Yes/No |  |
| Infrastructure Implementation Agent | `SUBAGENT_PROMPTS.md` |  | Yes/No |  |
| QA/Test Implementation Agent | `SUBAGENT_PROMPTS.md` |  | Yes/No |  |
| Review Agent | `SUBAGENT_PROMPTS.md` |  | Yes/No |  |
| Security Review Agent | `SUBAGENT_PROMPTS.md` |  | Yes/No |  |
