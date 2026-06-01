# Domain Orchestrator Card

Use this card when the Root Orchestrator delegates a domain slice to a separate Domain Orchestrator.
For small or medium slices, the Root may hold the Domain Orchestrator role inline instead.

Follow:

- `AGENTS.md`
- `docs/agent-rules/hybrid-orchestration.md`
- `docs/agent-rules/roles.md`
- `docs/agent-rules/subagent-execution.md` when launching workers
- active workspace profile when app-scoped

## Activation

- Epic / Task:
- Domain:
- Domain Orchestrator:
- Workflow mode:
- Active workspace:
- Workspace profile:
- Contract references:

## Domain Scope

- Owned outcome:
- Owned files/folders:
- Read-only context:
- Explicitly out of scope:
- Forbidden paths:

## Dependency Nodes

| Node | Status | Prerequisites | Unlocks | Owner | Verification |
| --- | --- | --- | --- | --- | --- |
|  | Proposed |  |  |  |  |

Allowed status values:

- `Proposed`
- `Ready`
- `In Progress`
- `Blocked`
- `Needs Confirmation`
- `Ready for Review`
- `Done`

## Worker Launch Rules

- Launch only nodes that are `Ready`.
- Use `docs/templates/SUBAGENT_TASK_CARD.template.md` for worker launches.
- Keep worker write scopes disjoint.
- Do not launch worker work that depends on an unresolved contract, security, workspace, verification, or Git decision.
- Stop and report `Needs Confirmation` if domain scope or dependencies are unclear.

## Checkpoints

- Checkpoint interval:
- Continue when:
- Re-scope or stop when:
- Escalation owner:

## Verification

- Domain-local checks:
- Contract-critical checks:
- Manual checks:

## Usage And Evaluation

- Expected system token usage: Low / Medium / High / exact count if available
- Main context drivers:
- Context intentionally omitted:
- Evaluation after return:
  - Was the domain orchestration layer worth the context cost?
  - Were worker cards compact enough?
  - What should be trimmed or kept for the next domain wave?

## Output Required

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
