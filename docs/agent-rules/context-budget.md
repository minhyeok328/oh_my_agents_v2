# Context Budget Rules

Use this file when preparing agent, subagent, review, or handover context.
The goal is to keep prompts small while preserving the rules needed for safe work.

## Core Principle

Load the smallest rule set that lets the current role act safely.
Prefer short task-local summaries and file references over pasting full rule files into every agent prompt.

## System Token Usage

System token usage means the operational context cost of system/developer instructions, root rules, skill instructions, workflow rules, workspace profiles, contracts, templates, task cards, and handovers.
It does not mean API tokens, credentials, secrets, auth tokens, or billable product token accounting.

For every workflow shape, keep system token usage proportional to risk:

- Default Workflow: load only the files needed for the local answer or edit.
- Formal Planning Workflow: load planning rules and directly relevant references, then summarize large source material.
- Full Delivery Workflow: load orchestration, role, workspace, contract, and review rules only when those gates apply.
- Hybrid or parallel work: send compact task cards instead of full planning packets, and include only the rule files needed by that role.
- Review, security, integration, and Git work: load the role-specific rules, evidence, and changed-file context required for the decision.

Record exact token counts only when the platform exposes them.
Otherwise record a qualitative estimate:

- Low: root rules plus a small number of focused files.
- Medium: several rule files, contracts, or task cards are required.
- High: broad planning packets, large specs, multiple contracts, or repeated handovers are required.

## Usage Evaluation

Evaluate usage before final handover or sync completion.
The evaluation should answer:

- Was each loaded rule file or prompt section necessary for safety?
- Could any large context have been replaced with a summary plus file reference?
- Did a subagent receive enough context to act without receiving unrelated history?
- Did the task card give enough skill guidance without forcing unrelated skill bodies into context?
- Did the extra context reduce risk, review cost, or coordination overhead enough to justify its size?
- What should be trimmed or kept for the next related task?

If usage is High, record why it was unavoidable or mark the work `Needs Confirmation` before launching more agents.

## Always-On Context

Every agent must follow:

- root `AGENTS.md`
- the user's explicit request
- the current Task, Subtask, or review assignment
- the declared workspace boundary for the task

Do not duplicate long sections from root rules in subagent prompts. Use concise reminders only when they prevent likely misuse.

## Role-Based Loading

Load detailed rules only when the role or task needs them:

| Situation | Load |
| --- | --- |
| Formal Planning, Full Delivery planning, Spec writing, or Task/Subtask creation | `docs/agent-rules/workflow.md` |
| Dependency-aware Epic, hybrid orchestration, or Root/Domain Orchestrator coordination | `docs/agent-rules/hybrid-orchestration.md` |
| Role assignment or multi-agent work | `docs/agent-rules/roles.md` |
| Subagent launch or integration | `docs/agent-rules/subagent-execution.md` |
| Active app or workspace-scoped implementation | `docs/agent-rules/workspaces.md` |
| Review-only work | `docs/agent-rules/review.md` |
| Security-triggered work | `docs/agent-rules/security-review.md` |
| Commit, branch, push, or PR work | `docs/agent-rules/commits.md` |
| Folder-level `AGENTS.md` creation | `docs/agent-rules/templates.md` |

If a rule file is not needed for the current role, reference it by path only or omit it.

## Skill Loading

Subagents should select relevant installed skills from their assigned role, mission, risk surface, and task card guidance.
The orchestrator should include skill names and intent, not full skill bodies, unless the exact skill text is needed for a fragile gate.

Task cards should distinguish:

- Required skills: must be used unless they conflict with higher-priority instructions.
- Suggested skills: likely useful, but the subagent decides whether they apply.
- Excluded skills: do not use because they would broaden scope or duplicate another role.

Skill instructions count toward System token usage after they are loaded.
Subagents must include `Skills used:` and a short usage evaluation in their output.

## Subagent Context Capsule

Implementation subagents should usually receive a compact task card, not the full planning packet.
Use `docs/templates/SUBAGENT_TASK_CARD.template.md` as the default shape.
Use `docs/agent-rules/subagent-execution.md` for launch gates, stop conditions, and output integration.

Minimum fields:

- active workspace
- profile path
- role
- Subtask reference
- dependency prerequisites and unlocks when hybrid orchestration applies
- required, suggested, or excluded skill guidance
- system token usage estimate and evaluation requirement
- allowed write scope
- read-only context
- forbidden paths
- owned outcome and checkpoint expectations
- verification commands
- stop conditions

## Heavy Context Rules

- Summarize large Specs, contracts, or handovers into task-local headers before launching subagents.
- Include full contracts only for agents that must implement or review against those contract details.
- Include security checklists only when a security trigger applies.
- Include commit rules only for explicit Git work.
- Do not include unrelated app, repo, or workspace history.

## Implementation Agent Defaults

Implementation agents should receive these reminders unless the Task explicitly says otherwise:

- Do not run Git commands.
- Do not commit, branch, push, or modify Git metadata.
- Do not edit outside the assigned write scope.
- Treat governance docs as read-only unless the assignment explicitly says to edit them.
- Stop and report if the work requires a contract, profile, security, or Git policy change.

## Output Discipline

Subagent output should be concise and reviewable:

- changed files
- skills used
- decisions made
- verification commands and results
- downstream unlocks or blocked dependencies when hybrid orchestration applies
- system token usage estimate and usage evaluation
- assumptions or `Needs Confirmation` items
- security-sensitive areas touched

Avoid restating all input context in the output.
