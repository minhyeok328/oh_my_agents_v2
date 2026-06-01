# Risk Register (Hybrid Agent Operation)

This register tracks workflow and architecture risks introduced by hybrid or parallel work, and how we mitigate them.

## How to Use

- Add new risks as they are discovered.
- For unknowns, use **Needs Confirmation**.
- Do not record secrets or production credentials.

## Risks

### R-001: Contract drift between agents

- Description: Agents implement based on different assumptions about interfaces.
- Impact: Integration failures, rework, inconsistent UX, broken deployments.
- Mitigation:
  - Contract-first gating (`docs/contracts/*`)
  - Sync point checklist (`docs/coordination/AGENT_SYNC_CHECKLIST.md`)
  - Integration review template
- Owner: Integration Coordinator Agent
- Status: Active

### R-002: Hidden coupling across Backend/DB/Frontend

- Description: A Subtask appears domain-scoped but requires cross-domain changes.
- Impact: Frequent interrupts, repeated reviews, slow progress.
- Mitigation:
  - Re-split Subtasks when coupling is discovered
  - Move shared parts into explicit contract updates first
- Owner: Task Agent
- Status: Active

### R-003: Dependency graph drift

- Description: A downstream node starts before its real prerequisites are satisfied.
- Impact: Rework, broken integration, false progress, stale task cards.
- Mitigation:
  - Hybrid orchestration dependency graph (`docs/agent-rules/hybrid-orchestration.md`)
  - Ready-node launch rule
  - Dependency Graph Status section in sync checklist
- Owner: Root Orchestrator / Domain Orchestrator
- Status: Active

### R-004: Security regressions during fast hybrid or parallel iteration

- Description: Auth/input/file/dependency changes slip through without full security review.
- Impact: Vulnerabilities, secret exposure, compliance risk.
- Mitigation:
  - Security Review Agent gate for security-sensitive scopes
  - Never commit real `.env` files; enforce `.gitignore`
- Owner: Security Review Agent
- Status: Active

### R-005: Workspace boundary violations (accidental)

- Description: Tools/scripts or commands access outside the repo.
- Impact: Data leakage, unintended modifications, irreproducibility.
- Mitigation:
  - Hard stop and escalate to user
  - Keep commands project-local
- Owner: All agents
- Status: Active

### R-006: OS-specific absolute paths in docs/specs

- Description: Specs include absolute paths that don't match teammates' OS.
- Impact: Confusion, broken instructions.
- Mitigation:
  - Prefer relative paths and repo-root references
  - Mark as Needs Confirmation if absolute path is unavoidable
- Owner: Spec Agent / Task Agent
- Status: Active

### R-007: System token usage drift

- Description: Agent prompts, task cards, handovers, or review packets grow without a recorded safety or coordination reason.
- Impact: Slower work, higher context cost, stale assumptions, missed scope boundaries.
- Mitigation:
  - Record Low/Medium/High or exact system token usage when available
  - Require usage evaluation in subagent, review, sync, and handover outputs
  - Trim full documents into summaries plus file references when safe
- Owner: Root Orchestrator / Domain Orchestrator
- Status: Active

### R-008: Validation blind spots

- Description: Documentation checks pass because required phrases exist, while links, secret-like values, or gate structure are broken.
- Impact: Agents trust incomplete governance docs and repeat unsafe patterns.
- Mitigation:
  - Validate internal Markdown links
  - Block tracked real `.env*` files except `.env.example`
  - Scan for strong secret-like token and private key patterns
  - Add structural checks when a new gate or template field becomes required
- Owner: Integration Coordinator Agent / QA-Test Implementation Agent
- Status: Active
