# Full Delivery Hybrid Start Checklist

## Metadata

- Task / Spec: Invalid blocked start fixture
- Date/time: 2026-06-20T00:00:00Z
- Root Orchestrator: Main Codex Session
- Integration Coordinator Agent: Inline
- Requested outcome: Demonstrate blocked start rejection
- Source request: dry-run fixture
- Active workspace: workspaces/sample-app
- Workspace profile: workspaces/sample-app/.agent/profile.md
- Related docs: `AGENTS.md`

## 1) Full Delivery Fit

- [x] The user explicitly requested Full Delivery Workflow, end-to-end delivery, hybrid orchestration, or parallel multi-agent delivery.

Decision:

- Workflow mode: Full Delivery Workflow
- Reason: Invalid fixture keeps a blocker while approving start.
- Why Default Workflow is not enough: fixture covers Full Delivery start gates.
- Orchestration shape: Hybrid

## 2) Workspace Activation Gate

- [x] Active workspace is declared as `workspaces/sample-app`.

Workspace status:

- Active workspace: workspaces/sample-app
- Workspace profile: workspaces/sample-app/.agent/profile.md
- Contract location: workspaces/sample-app/.agent/contracts
- Allowed write roots: workspaces/sample-app/src/api
- Forbidden paths: .git, real env files, other workspaces
- Git steward: Required before commit
- Git target: active app

## 3) Context Budget Gate

- [x] User explicitly requested subagents, delegation, hybrid orchestration, or parallel agent work before any Superpowers `spawn_agent` call.

Context notes:

- Subagent card template: docs/templates/SUBAGENT_TASK_CARD.template.md

## 4) System Token Usage Gate

- [x] Expected system token usage is recorded for Root, each Domain Orchestrator, and each worker prompt.

System token usage plan:

- Root / invalid node: Low.

## 5) Dependency Graph Gate

- [x] Root Orchestrator is assigned.

Dependency graph:

- Node: invalid node; Domain: backend; Owner: Backend Implementation Agent; Status: Blocked; Prerequisites: unresolved contract; Unlocks: none; Verification: none

## 6) Domain Impact Map

- [x] Backend application logic / APIs

Notes:

- Primary domains: backend

## 7) Contract Gate

- [x] `API_CONTRACT.md` reviewed.

Contract status:

- API_CONTRACT.md: applies yes; status needs work; reviewer Review Agent; notes unresolved blocker remains

## 8) Ownership Gate

- [x] Each Subtask has one primary domain owner.

Ownership map:

- Subtask: invalid blocked start; Primary Agent: Backend Implementation Agent; Owned Outcome: rejected fixture; Owned Files/Folders: workspaces/sample-app/src/api; Dependencies: unresolved contract

## 9) Security Trigger Gate

- [x] No security trigger applies

Security decision:

- Security Review Agent required: No
- Reason: invalid docs-only fixture
- Security checklist location: not applicable

## 10) Verification Plan

- [x] Unit test command identified.

Verification commands:

- Unit tests: npm.cmd test; Owner: Backend Implementation Agent; Required: Yes

## 11) Sync Plan

- [x] Sync checklist selected: `docs/coordination/AGENT_SYNC_CHECKLIST.md`

Sync points:

- Contract approval: before implementation; participants Integration Coordinator and Review Agent; evidence missing.

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

Decision:

- Start approved: Yes
- Approved by: Root Orchestrator
- Conditions: none
- Blocking items: unresolved contract

## 13) Subagent Launch Notes

Launch order:

1. This fixture should never launch because blocking items remain.
