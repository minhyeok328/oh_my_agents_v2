# Agent Sync Checklist

Use this checklist at every planned sync point when hybrid or parallel work is active.

## 1) Workspace Status

- [ ] Active workspace is declared when implementation targets `workspaces/<app-slug>`
- [ ] Workspace profile is available or marked `Needs Confirmation`
- [ ] Changed files are inside the active workspace unless shell-governance changes were explicitly assigned
- [ ] No other `workspaces/*` app was read or modified without explicit approval
- [ ] Implementation agents did not run Git commands or modify Git metadata
- [ ] Git steward status is recorded for any commit, branch, push, or PR follow-up

## 2) Contract Status

- [ ] `docs/contracts/API_CONTRACT.md` updated and approved (if API touched)
- [ ] `docs/contracts/DB_SCHEMA_CONTRACT.md` updated and approved (if schema/migrations touched)
- [ ] `docs/contracts/FRONTEND_BACKEND_CONTRACT.md` updated and approved (if UI↔API touched)
- [ ] `docs/contracts/INFRA_DEPLOYMENT_CONTRACT.md` updated and approved (if CI/deploy/env wiring touched)
- [ ] Relevant contracts include a filled **Parallel Start Minimum** section
- [ ] Any remaining unknowns are marked **Needs Confirmation** (no guessing codified as rules)

## 3) Dependency Graph Status

- [ ] Current wave or ready-node set is recorded
- [ ] Newly completed nodes have their downstream unlocks checked
- [ ] Newly ready nodes may start without waiting for unrelated in-progress nodes
- [ ] Blocked nodes have an owner and next decision path
- [ ] No node was launched before its prerequisites were satisfied

## 4) Ownership & Scope

- [ ] Each subagent returned `Status: Completed`, `Blocked`, or `Needs Confirmation`
- [ ] Each subagent task card declared an owned outcome and checkpoint expectations
- [ ] Checkpoints were treated as continue/re-scope/escalate decisions, not forced timeouts
- [ ] Orchestrator checked returned changed files against each task card
- [ ] Backend changes are confined to backend-owned files
- [ ] DB changes are confined to migration/schema-owned files
- [ ] Frontend changes are confined to frontend-owned files
- [ ] Infra changes are confined to infra/CI-owned files
- [ ] QA/Test changes are confined to tests/verification scaffolding
- [ ] No agent changed unrelated behavior or files

## 5) Security Gates

- [ ] No secrets were introduced (no tokens/passwords/keys)
- [ ] `.env`, `.env.local`, and real `.env.*` are not tracked
- [ ] Security Review Agent ran checklist when triggered by scope

## 6) Integration Readiness

- [ ] API response shapes match frontend expectations
- [ ] DB migrations (if any) are compatible with deploy strategy
- [ ] Infra env var names match `.env.example` structure (dummy only)
- [ ] Error handling is consistent and does not leak internals

## 7) Verification

Project-specific commands:

- [ ] Lint command executed
- [ ] Unit tests command executed
- [ ] Integration tests for contract-critical paths executed
- [ ] Build command executed

If a command is not configured yet, record "Not applicable yet" with reason and owner.

## 8) Token Usage And Evaluation

- [ ] System token usage was captured as exact counts when available, otherwise Low/Medium/High.
- [ ] High-usage prompts have a recorded reason tied to safety, contract, security, or integration needs.
- [ ] Subagent outputs include usage evaluation and context trim/keep notes.
- [ ] The next wave can use a smaller context packet where safe.
- [ ] No task card carried unrelated history or full documents when summaries would suffice.

## 9) Drift Handling

- [ ] If any drift exists, contract is updated first
- [ ] Subtasks are re-split if drift indicates coupling was underestimated
- [ ] Any `Needs Confirmation` item from subagent output is resolved before final handover

## 10) Cross-Agent Sync

- [ ] Each worker reported status through the orchestrator or Integration Coordinator
- [ ] `Needs Confirmation` items were routed through the orchestrator
- [ ] Contract-impacting findings updated contracts before implementation continued
- [ ] No private worker-to-worker assumptions remain
- [ ] Handover notes are attached to dependent Subtasks
- [ ] Any direct worker-to-worker question was explicitly allowed, narrow, and reported back
