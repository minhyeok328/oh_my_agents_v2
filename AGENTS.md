# AGENTS.md

This file defines the always-on rules for agents in this project.

For Korean onboarding context, see [docs/onboarding/USER_GUIDE.ko.md](./docs/onboarding/USER_GUIDE.ko.md).
Detailed operating rules live under [docs/agent-rules/](./docs/agent-rules/). Load those files only when the current task requires them.

## Instruction Priority

Agents must follow instructions in this order:

1. User's explicit instructions.
2. This root `AGENTS.md`.
3. The nearest folder-level `AGENTS.md` file for local rules that do not weaken root rules.
4. On-demand rule files under `docs/agent-rules/`.
5. General agent defaults.

If instructions conflict, the higher-priority instruction wins. If the correct action is unclear, stop and ask the user before continuing.

## Always-On Safety Rules

These rules apply to every task, regardless of size:

1. Work only inside the current project workspace.
2. Do not read, edit, move, delete, or format files outside the workspace.
3. Do not modify unrelated files or unrelated behavior.
4. Prefer existing project patterns over new abstractions.
5. Run relevant tests, checks, or verification commands before marking work complete.
6. Security, correctness, and maintainability take priority over speed.
7. Never hardcode real secrets or API tokens from `.env`, `.env.local`, or other environment variable files into source code.
8. Never commit real environment files, credentials, local databases, generated secrets, or secret-like values.
9. Share environment structure only through `.env.example` with dummy values.
10. Keep teammate-facing guidance aligned with this file; `AGENTS.md` is the operational source of truth.

## Workspace Boundary

Allowed inside the workspace:

- Read project files.
- Create, edit, move, or delete files required for the approved task.
- Run project-local commands for development, testing, formatting, and verification.
- Generate temporary, cache, or build artifacts inside the workspace.

Forbidden:

- Do not access unrelated projects, parent directories, user home files, global config files, shell profiles, IDE settings, or OS-level settings.
- Do not use `../` paths to access unrelated projects.
- Do not install or change global dependencies unless explicitly approved by the user.
- Do not run destructive commands outside the approved task scope.
- Do not read heavy unmanaged files such as `.git` internals, large logs, build artifacts, or data files of tens of MB or more unless the user explicitly requests it.
- Do not add `.env`, `.env.local`, or other real environment files to Git.

If a task appears to require access outside the workspace, stop and ask for explicit user approval.

## Tool And Skill Access

Project file work must stay inside this workspace.
Platform-provided tools, plugin metadata, and installed skills may live outside the workspace; agents may read or invoke them when required by higher-priority system or developer instructions, or when the user explicitly asks to install or use them.
This exception does not permit reading unrelated user files, editing non-tool files outside the workspace, or weakening the Workspace Boundary rules above.
Agents and subagents should choose relevant installed skills from the assigned task, role, and risk surface.
An orchestrator may list required, suggested, or excluded skills in a task card, but each subagent remains responsible for invoking any applicable skill and reporting which skills were used.
Skill use must stay inside the assigned scope and must not broaden workspace access, Git authority, security authority, or verification responsibilities.

## Workflow Modes

Use the lightest safe workflow by default.
Do not use numbered workflow categories for ordinary work.

### Default Workflow

Use this for questions, analysis, read-only inspection, small edits, focused fixes, routine implementation slices, and other work that can be handled safely from local context.

- Answer, inspect, or implement directly.
- Keep scope narrow and avoid unrelated changes.
- Run relevant verification before reporting completion.
- Self-review for scope, correctness, and workspace safety.
- Do not create Spec, Task/Subtask, Review Agent, or handover artifacts unless the user explicitly asks for Formal Planning, Full Delivery, formal tracking, or the work is already part of an existing formal workflow.

### Formal Planning Workflow

Use this when the user asks for a Spec, design, implementation plan, Task/Subtask breakdown, handoff, or other planning artifact without asking the agent to implement the work.

- Clarify only what is needed to make the planning artifact accurate.
- Write or update the requested planning artifact.
- Do not implement product changes unless the user explicitly approves moving into implementation.
- Keep verification limited to document consistency, links, and any checks relevant to the planning artifact.

### Full Delivery Workflow

Use the formal planning-through-development workflow only when the user explicitly asks the agent to own the work from initial planning through Spec writing and development, or when the user asks for end-to-end delivery, hybrid orchestration, or parallel multi-agent delivery.

A request for a Spec, implementation plan, handoff, or bounded subagent/delegation by itself does not switch the task into Full Delivery Workflow.

The Full Delivery Workflow may include:

- initial planning and requirement clarification
- Spec writing or update
- Task/Subtask breakdown
- dependency-aware hybrid orchestration when multiple domains or agents are involved
- contract-first coordination before dependent implementation starts
- implementation one Subtask at a time
- Review Agent and Security Review Agent checks when applicable
- explicit verification and handover

If Formal Planning or Full Delivery appears necessary for safety but the user did not request it, explain why and ask before switching into it.

## On-Demand Rule Loading

Load only the files needed for the current task:

- Formal Planning and Full Delivery workflow details: [docs/agent-rules/workflow.md](./docs/agent-rules/workflow.md)
- Dependency-aware hybrid orchestration: [docs/agent-rules/hybrid-orchestration.md](./docs/agent-rules/hybrid-orchestration.md)
- Role definitions and multi-agent ownership: [docs/agent-rules/roles.md](./docs/agent-rules/roles.md)
- Context budget and rule-loading discipline: [docs/agent-rules/context-budget.md](./docs/agent-rules/context-budget.md)
- Subagent launch and integration protocol: [docs/agent-rules/subagent-execution.md](./docs/agent-rules/subagent-execution.md)
- Active app workspace rules: [docs/agent-rules/workspaces.md](./docs/agent-rules/workspaces.md)
- Review formats and expectations: [docs/agent-rules/review.md](./docs/agent-rules/review.md)
- Security checklist and security review output: [docs/agent-rules/security-review.md](./docs/agent-rules/security-review.md)
- Commit rules: [docs/agent-rules/commits.md](./docs/agent-rules/commits.md)
- Folder-level templates: [docs/agent-rules/templates.md](./docs/agent-rules/templates.md)

## Security Review Triggers

Load `docs/agent-rules/security-review.md` and run the security checklist when a task touches:

- authentication, sessions, cookies, tokens, passwords, or redirects
- authorization, roles, ownership, admin behavior, or resource access
- user input from body, query, params, headers, forms, files, or external APIs
- database schemas, migrations, queries, data storage, or sensitive data
- file upload, download, paths, generated files, or public file access
- external APIs, webhooks, network calls, dependencies, or configuration
- logging, analytics, monitoring, environment variables, or secrets

If a Blocker security issue is found, stop and escalate to the user.

## Commit Rule

Commits must follow Conventional Commits 1.0.0.

Before committing, load [docs/agent-rules/commits.md](./docs/agent-rules/commits.md).
Use the `commit-workflow` skill for staging, splitting, rewriting, writing commit messages, and creating commits.
Implementation agents must not perform Git work unless explicitly assigned Git Steward responsibilities.

## Progress and Deadlock

- Keep the user informed during long-running work.
- If work continues for 4 minutes, provide a short status update with the active workflow mode, active role or Subtask when applicable, current action, and early findings.
- If there is no meaningful progress for 5 minutes, stop and provide a handover summary instead of silently retrying.
- For delegated or subagent work, use time guidance as a checkpoint mechanism, not a forced timeout. Keep the assigned scope owned by that agent while there is meaningful progress.
- Re-scope, add context, or escalate delegated work when checkpoints show no meaningful progress, scope drift, unsafe behavior, or a repeated blocker.
- If the same fix/re-review loop, test failure, or implementation deadlock repeats three consecutive times, stop and ask the user for guidance.

## Completion

Before marking work complete:

- Verify the task matches the user's request and the selected workflow mode.
- Confirm unrelated behavior was not changed.
- Run relevant checks or explain why they are not applicable.
- Report changed files, verification results, assumptions, and residual risks.
