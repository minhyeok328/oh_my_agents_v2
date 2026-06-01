# Cross-Agent Handover Template

Use this handover when passing work across domain agents during hybrid or parallel execution.

## Context

- Current Task / Subtask:
- Date/time:
- From Agent:
- To Agent:
- Routed via Orchestrator / Integration Coordinator: yes/no
- Direct worker-to-worker communication approved: yes/no/not applicable
- Active workspace:
- Workspace profile:
- Contract references:
  - `docs/contracts/...`

## What Changed

- Subagent status: Completed | Blocked | Needs Confirmation
- Changed files:
- Contract changes:
  - (yes/no) If yes, list contract sections updated.
- Scope statement:
  - Confirm changes stayed inside the active workspace and owned write scope.

## What You Need To Know (For Receiver)

- Intended behavior:
- Edge cases:
- "Needs Confirmation" items:
- Contract drift or shared-interface concerns:
- Follow-up required:
- Non-obvious constraints:

## Verification Status

- Commands run + results:
- Not run (and why):

## Token Usage

- Token usage notes:
- Exact count if available:
- Estimate if count is unavailable: Low / Medium / High
- Evaluation:
  - Necessary context:
  - Context that can be trimmed next time:

## Risks / Security Notes

- Any secret exposure risk? (must be "no"; if unsure, stop and escalate)
- Auth/input/file/deps touched? (yes/no; details)

## Next Steps (Receiver Checklist)

- [ ] Re-read relevant contracts
- [ ] Confirm active workspace and workspace profile
- [ ] Confirm scope ownership
- [ ] Implement only within owned files
- [ ] Do not run Git commands unless assigned Git Steward work
- [ ] Report back with verification results
