# Full Delivery Hybrid Start Checklist

## Metadata

- Task / Spec: Fixture delivery readiness validation
- Date/time: 2026-06-20T00:00:00Z
- Root Orchestrator: Main Codex Session
- Integration Coordinator Agent: Inline
- Requested outcome: Validate filled orchestration artifacts
- Source request: dry-run fixture
- Active workspace: workspaces/sample-app
- Workspace profile: workspaces/sample-app/.agent/profile.md
- Related docs: `AGENTS.md`, `docs/agent-rules/workflow.md`, `docs/agent-rules/subagent-execution.md`

## 1) Full Delivery Fit

- [x] The user explicitly requested Full Delivery Workflow, end-to-end delivery, hybrid orchestration, or parallel multi-agent delivery.
- [x] The work is large enough, cross-domain enough, dependency-heavy enough, or parallel enough to justify formal coordination.
- [x] The expected work can be split into independently owned Subtasks.
- [x] The user request and acceptance target are understood.

Decision:

- Workflow mode: Full Delivery Workflow
- Reason: Fixture proves the readiness checker accepts completed gates.
- Why Default Workflow is not enough: fixture covers Full Delivery start gates.
- Orchestration shape: Hybrid

## 2) Workspace Activation Gate

- [x] Active workspace is declared as `workspaces/sample-app`.
- [x] Workspace profile exists.
- [x] Only one active workspace is in scope for this task.
- [x] Other `workspaces/*` apps are out of scope.
- [x] Governance docs are read-only unless this task explicitly assigns policy/template changes.
- [x] Implementation agents will not run Git commands or modify Git metadata.
- [x] Git Steward will use `docs/agent-rules/commits.md` and `commit-workflow` when commit work is required.

Workspace status:

- Active workspace: workspaces/sample-app
- Workspace profile: workspaces/sample-app/.agent/profile.md
- Contract location: workspaces/sample-app/.agent/contracts
- Allowed write roots: workspaces/sample-app/src/api, workspaces/sample-app/tests/api
- Forbidden paths: .git, real env files, other workspaces
- Git steward: Required before commit
- Git target: active app

## 3) Context Budget Gate

- [x] User explicitly requested subagents, delegation, hybrid orchestration, or parallel agent work before any Superpowers `spawn_agent` call.
- [x] Default Workflow automatic delegation is not being used.
- [x] Orchestrator has selected the immediate local critical-path task.
- [x] Delegated subtasks are non-overlapping and can run when their dependency prerequisites are satisfied.
- [x] Subagents will receive compact task cards with owned outcomes and checkpoint expectations instead of full planning packets.

Context notes:

- Subagent card template: docs/templates/SUBAGENT_TASK_CARD.template.md
- Domain Orchestrator card template: docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md
- Skill policy: subagents choose relevant installed skills unless excluded
- Full docs required: none for this fixture
- Summaries prepared: task-local summary only

## 4) System Token Usage Gate

- [x] Expected system token usage is recorded for Root, each Domain Orchestrator, and each worker prompt.
- [x] Exact counts will be used when available; otherwise each prompt is estimated as Low, Medium, or High.
- [x] High-usage prompts have a reason tied to safety, contracts, security, or integration risk.
- [x] Each delegated task card includes context intentionally omitted.

System token usage plan:

- Root / fixture node: Low, driven by task card and active API contract.

## 5) Dependency Graph Gate

- [x] Root Orchestrator is assigned.
- [x] Domain Orchestrators are assigned or explicitly held inline by Root.
- [x] Dependency nodes are listed with owners, statuses, prerequisites, unlocks, and verification.
- [x] Nodes that can start now are marked `Ready`.
- [x] The first wave does not require waiting for unrelated domains to finish before downstream ready work can start.

Dependency graph:

- Node: API fixture implementation; Domain: backend; Owner: Backend Implementation Agent; Status: Ready; Prerequisites: active API contract; Unlocks: review fixture; Verification: npm.cmd test

## 6) Domain Impact Map

- [x] Backend application logic / APIs
- [x] QA / tests / fixtures / verification automation

Notes:

- Primary domains: backend, QA
- Secondary domains: none
- Out of scope: frontend, database, infrastructure

## 7) Contract Gate

- [x] `API_CONTRACT.md` reviewed.
- [x] Every relevant contract has a filled "Parallel Start Minimum" section.
- [x] No domain agent is expected to guess shared interface behavior.
- [x] Review Agent has approved the relevant contract set.

Contract status:

- API_CONTRACT.md: applies yes; status approved; reviewer Review Agent; notes fixture contract only

## 8) Ownership Gate

- [x] Each Subtask has one primary domain owner.
- [x] Owned files/folders are explicitly listed for each Subtask.
- [x] Owned outcome and checkpoint expectations are explicitly listed for each delegated Subtask.
- [x] Cross-domain changes are represented as contract updates plus separate owned Subtasks.
- [x] No Subtask requires two agents to edit the same file at the same time.

Ownership map:

- Subtask: API fixture; Primary Agent: Backend Implementation Agent; Owned Outcome: API fixture implementation; Owned Files/Folders: workspaces/sample-app/src/api and tests/api; Dependencies: active API contract

## 9) Security Trigger Gate

- [x] User input from body, query, params, headers, forms, files, or external APIs

Security decision:

- Security Review Agent required: Yes
- Reason: API behavior receives request input.
- Security checklist location: docs/agent-rules/security-review.md

## 10) Verification Plan

- [x] Unit test command identified.
- [x] Contract-critical verification is assigned to a responsible agent.

Verification commands:

- Unit tests: npm.cmd test; Owner: Backend Implementation Agent; Required: Yes

## 11) Sync Plan

- [x] Sync checklist selected: `docs/coordination/AGENT_SYNC_CHECKLIST.md`
- [x] Integration review template selected: `docs/templates/INTEGRATION_REVIEW_TEMPLATE.md`
- [x] Hybrid unlock rule is understood: newly ready downstream nodes may start without waiting for unrelated in-progress nodes.
- [x] Sync points are defined before implementation starts.

Sync points:

- Contract approval: before implementation; participants Integration Coordinator and Review Agent; evidence approved contract notes.

## 12) Start Decision

- [x] Full Delivery fit confirmed.
- [x] Workspace activation confirmed or marked not applicable.
- [x] Context budget gate confirmed.
- [x] System token usage gate confirmed.
- [x] Dependency graph gate confirmed.
- [x] Relevant contracts approved.
- [x] Ownership map complete.
- [x] Security review requirement decided.
- [x] Verification plan complete.
- [x] Sync plan complete.
- [x] No blocking `Needs Confirmation` items remain.

Decision:

- Start approved: Yes
- Approved by: Root Orchestrator
- Conditions: stay inside fixture scope
- Blocking items: none

## 13) Subagent Launch Notes

Launch order:

1. Root Orchestrator confirms the dependency graph and first ready wave.
2. Integration Coordinator Agent confirms contracts and ownership.
3. Backend Implementation Agent begins only the approved owned Subtask.
4. Review Agent reviews the completed Subtask.
