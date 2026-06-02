# Subagent Execution Rules

Use this file when the main Codex session prepares, launches, receives, or integrates subagent work.
Use `docs/agent-rules/hybrid-orchestration.md` first when subagents are part of dependency-aware Epic or cross-domain work.

Subagents do not choose their own workspace, write scope, Git behavior, or verification strategy.
Subagents do choose which installed skills apply to their assigned task unless the task card explicitly marks a skill as required or excluded.
The main Codex session acts as the orchestrator and must launch subagents with a bounded task card.
If boundaries are unclear, the subagent stops and reports `Needs Confirmation` instead of guessing.

## Purpose

This protocol defines how subagents are called and integrated.
It keeps subagent work scoped, reviewable, and cheap enough to use deliberately.

Subagents are opt-in execution resources, not the default execution path.
The default path is for the main Codex session to handle the work locally.
In hybrid orchestration, each subagent should map to a dependency node with explicit prerequisites and unlocks.
System token usage must be estimated before launch and evaluated after return so delegation stays cheaper than local execution plus review.

Use it for:

- approved Full Delivery hybrid or parallel work
- domain-owned implementation subtasks
- Domain Orchestrator work that is large enough to justify a separate coordination layer
- review, security review, integration, or Git work that should be separated from implementation
- any task where a compact task card is safer than broad shared context

Do not use subagents just because they are available.
If the main Codex session can safely complete a Default Workflow task with less context, do that instead.

## Delegation Policy

Use workflow mode and explicit user approval to decide whether delegation is worth the cost:

| Workflow | Delegation default | Rule |
| --- | --- | --- |
| Default Workflow | Do not delegate by default | Questions, explanations, small edits, and focused fixes should stay local unless the user explicitly asks for delegation. |
| Formal Planning Workflow | Conditional | Delegate only bounded research, review, or planning checks when the user explicitly asks for delegation or a separate pass. |
| Full Delivery Workflow | Conditional | Delegate only approved, bounded work with explicit scope and a useful review, security, integration, Git, hybrid, or parallel benefit. |

Workflow mode alone does not authorize spawning.
Actual Superpowers `spawn_agent` use requires the user to explicitly ask for subagents, delegation, hybrid orchestration, or parallel agent work.
If the user did not ask for delegation, the orchestrator should keep work local or ask before spawning.

## Superpowers Harness Gate

When the local Codex/Superpowers multi-agent harness is available, use it only after the delegation policy allows it.

Available harness actions may include:

- `spawn_agent`: create a bounded `explorer`, `worker`, or default subagent
- `wait_agent`: wait only when the next critical-path step is blocked on the result
- `send_input`: continue or redirect an existing agent
- `close_agent`: close agents that are no longer needed

Before calling `spawn_agent`, the orchestrator must:

- confirm the user explicitly asked for subagents, delegation, hybrid orchestration, or parallel agent work
- choose one immediate local task to keep moving on the critical path
- delegate only non-overlapping work that is ready in the dependency graph
- avoid delegating urgent blocking work when doing it locally is faster or safer
- ensure coding workers have disjoint write scopes
- avoid duplicate agents on the same unresolved task

## 1. Orchestrator Responsibilities

The main Codex session is the orchestrator.
Before launching a subagent, it must:

- confirm whether the task is Default Workflow, Formal Planning Workflow, or Full Delivery Workflow
- confirm the active workspace when app-scoped
- read the workspace profile when available
- identify allowed write scope and forbidden paths
- decide whether hybrid orchestration or pure parallel execution applies
- decide whether contracts are required
- identify dependency nodes, prerequisites, and downstream unlocks when hybrid orchestration applies
- decide whether security review is triggered
- decide whether Git Steward work is required
- define the skill policy for the task card: required skills, suggested skills, and excluded skills when applicable
- estimate System token usage and define the Usage evaluation expected from the subagent
- create or fill a Subagent Task Card
- keep the user informed during long-running work

The orchestrator remains responsible for final integration.
Subagent output is evidence, not automatic approval.

## Ownership And Checkpoints

Subagent delegation should create small, owned work rather than temporary help.
The task card must define the outcome the subagent owns and the checkpoint expectations for that work.

Time guidance for subagents is a checkpoint mechanism, not a forced timeout.
At each checkpoint, the orchestrator should decide whether to continue, provide missing context, narrow the scope, assign review, or stop and escalate.

Continue the assigned work with the same subagent when:

- the subagent is still inside the allowed scope
- the output or status shows meaningful progress toward the owned outcome
- the remaining work is still the same bounded task
- verification or review is pending but the path is clear

Re-scope, stop, or escalate when:

- checkpoints show no meaningful progress
- the subagent reports `Blocked` or `Needs Confirmation`
- scope has drifted beyond the task card
- the work requires a contract, security, workspace, or Git policy change that was not assigned
- the same blocker, verification failure, or review loop repeats three consecutive times

The orchestrator must not reclaim work just because a checkpoint occurs.
If the subagent owns a clear scope and is making progress, let it carry that scope to completion.

## 2. When To Use A Subagent

Use a subagent when:

- the user explicitly requested bounded delegation and the work can be isolated
- Full Delivery hybrid or parallel work is active
- a domain-owned Subtask can be isolated
- a Domain Orchestrator can reduce context pressure for a large domain slice
- review, security review, integration, or Git work should be separated from implementation
- context can be reduced by sending a focused task card
- a bounded second pass is useful for correctness, security, or scope control

Do not use a subagent when:

- the task is a Default Workflow item that the main session can complete safely
- the main Codex session can safely complete the work with less context
- the active workspace or write scope is unclear
- the subagent would need broad repo-wide judgment without a bounded mission
- the expected output cannot be reviewed or verified

## 3. Pre-Launch Gate

A subagent may start only when:

- delegation is explicitly requested or approved for this task
- active workspace is declared or marked not applicable
- role is selected
- task card is filled
- allowed write scope is explicit
- forbidden paths are explicit
- verification command is defined or marked `Needs Confirmation`
- skill selection policy is explicit, even if it says `Required: none` and `Suggested: choose by role`
- System token usage estimate is recorded as Low, Medium, High, or exact count when available
- Usage evaluation is required in the return output
- stop conditions are included
- Git behavior is explicit

Implementation agents must not run Git commands, commit, branch, push, or modify Git metadata.

For Full Delivery hybrid or parallel work, also confirm:

- relevant contracts are reviewed or marked `Needs Confirmation`
- ownership overlap has been checked
- dependency prerequisites and downstream unlocks are known or marked `Needs Confirmation`
- security trigger decision is recorded
- sync or review path is known

If any required gate is missing, do not launch the subagent.
Fix the task card, update the profile or contract, or ask the user for clarification.

## 4. Task Card Rules

Use:

```text
docs/templates/SUBAGENT_TASK_CARD.template.md
```

The task card must be self-contained enough that the subagent can act without reading unrelated planning docs.

Required fields:

- active workspace
- workspace profile
- task or Subtask reference
- role
- dependency prerequisites and unlocks when hybrid orchestration applies
- required read context
- skill selection guidance
- allowed write scope
- read-only context
- forbidden paths
- system token usage estimate and usage evaluation prompt
- mission
- acceptance criteria
- verification
- ownership and checkpoint expectations
- stop conditions
- output required

Do not paste full rule files into the card unless the subagent must act on exact wording.
Summarize the relevant rule in 5-10 lines and cite the file path.

The task card must not expand the root workspace boundary or weaken any rule from `AGENTS.md`.

## 5. Skill Selection

Subagents are responsible for deciding which installed skills apply to their assigned task.
The orchestrator should provide skill guidance without pasting full skill bodies into the task card.

Use this policy:

- Required skills: use only when the user, root rules, task card, or role-specific rule explicitly requires the skill.
- Suggested skills: list likely relevant skills by name, but the subagent still decides whether each one applies.
- Excluded skills: list skills that would broaden scope, trigger the wrong workflow, or duplicate another assigned role.
- Additional skills: the subagent may use another installed skill if it clearly applies to the task and does not expand scope.
- Conflict handling: if a required skill appears inapplicable or conflicts with higher-priority instructions, stop and report `Needs Confirmation`.

Skill selection must not change the assigned workspace, write scope, Git authority, security review authority, or verification owner.
Each subagent must report `Skills used:` in its output.

## 6. Cross-Agent Communication

Subagents should not coordinate through private, untracked assumptions.
Cross-agent information must flow through the orchestrator or Integration Coordinator by default.

Allowed cross-agent communication:

- status updates
- `Needs Confirmation` items
- contract drift reports
- handover notes
- verification results
- narrow factual questions routed by the orchestrator

Not allowed:

- changing shared interface behavior by direct worker-to-worker agreement
- editing another agent's owned files
- broadening scope without an updated task card
- treating a private worker answer as a contract update
- bypassing Integration Coordinator for contract-impacting decisions

Direct worker-to-worker communication is allowed only when the orchestrator explicitly permits it for a narrow question.
The result must be reported back to the orchestrator.
If the answer changes shared behavior, update the contract first and relaunch affected task cards.

## 7. Role-Specific Inputs

Add role-specific input to the task card.

Implementation Agent:

- owned files or folders
- acceptance criteria
- verification commands
- contract references if relevant
- explicit out-of-scope files

Review Agent:

- changed file list or diff summary
- original task card
- implementation output
- acceptance criteria
- verification results

Security Review Agent:

- security triggers
- changed files
- relevant checklist sections
- implementation output
- secret-handling notes

Integration Coordinator:

- active contracts
- ownership map
- dependency graph or ready-node list when hybrid orchestration applies
- sync checklist
- dependency or drift notes

Git Steward Agent:

- changed file list
- intended commit target
- shell/app repo distinction
- commit rules path
- staging or PR intent
- workspace profile Git Pointer for app-scoped work

## 8. Stop Conditions

A subagent must stop and report `Needs Confirmation` when:

- the assigned write scope is too broad or missing
- required files are outside the active workspace
- another workspace must be touched
- contract behavior is unclear
- verification command is missing or unsafe to infer
- security trigger is discovered but no Security Review Agent is assigned
- Git work is required but the subagent is not Git Steward
- real secrets or environment files appear necessary
- the task requires weakening root or workspace rules

Stopping is the correct behavior when boundaries are unclear.
Do not broaden scope silently.

## 9. Required Output

Every subagent must return a compact, reviewable output.

Required fields:

```md
- Status: Completed | Blocked | Needs Confirmation
- Changed files:
- Summary:
- Skills used:
- Verification:
- Contract impact:
- Security impact:
- Assumptions:
- Follow-up required:
- System token usage:
- Usage evaluation:
```

Review and Security Review Agents may use their role-specific formats, but they must still include a clear status.

If no files changed, write `Changed files: none`.
If no skills were used beyond always-on instructions, write `Skills used: none`.
If verification was not run, explain why and name the owner or condition needed to run it.
If exact token counts are unavailable, report System token usage as Low, Medium, or High and explain the main context drivers.

## 10. Integration After Return

After a subagent returns, the orchestrator must:

1. Check the returned status.
2. Confirm changed files stayed inside the allowed scope.
3. Confirm no forbidden paths, other workspaces, `.git/**`, real env files, or secrets were touched.
4. Compare the output against acceptance criteria.
5. Check `Skills used:` against the task card's required, suggested, and excluded skill policy.
6. Review verification commands and results.
7. Evaluate System token usage against the task value and context budget.
8. Decide whether Review Agent is needed.
9. Decide whether Security Review Agent is needed.
10. Update contracts, task docs, or handover notes if required.
11. Record unresolved `Needs Confirmation` items.
12. Mark downstream dependency nodes `Ready` only when their prerequisites are satisfied.
13. Start newly ready work without waiting for unrelated in-progress nodes when the workflow is hybrid.
14. Avoid commit, branch, push, or PR work unless acting through Git Steward rules.

When Git Steward work is required, load `docs/agent-rules/commits.md`, use `commit-workflow`, and classify shell/app changes before staging.

For Full Delivery hybrid or parallel work, run the relevant sync checklist before final handover:

```text
docs/coordination/AGENT_SYNC_CHECKLIST.md
```

The orchestrator must not treat subagent completion as final completion until scope, verification, and review requirements are satisfied.
