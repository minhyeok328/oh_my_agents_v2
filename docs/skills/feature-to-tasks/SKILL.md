---
name: feature-to-tasks
description: Use when the user provides a feature issue in an epic/feature/task hierarchy and wants its child task issues generated. Requires Codex to read the feature issue and the relevant workspace code first, break the feature into small implementation-level task issues, and output copy-ready Markdown task issues that link back to the parent feature. Output Markdown only — never create issues remotely.
---

# Feature → Tasks

Use this skill whenever the user shows a feature issue and asks to generate its child task issues. The hierarchy is **epic → feature → task**: the input is one feature, the output is the set of tasks needed to implement it.

- **Copy-only: do not change code or create issues remotely.**
- **Write the tasks in the user's language** (default Korean if unclear); keep the `type(scope): summary` title and code identifiers as-is.

## Required workflow

1. Read the feature and the code before splitting:
   - Parse the feature issue: its goal, scope, acceptance criteria, and any linked epic.
   - List the folder structure (e.g. `git ls-files`, directory listing, or glob) and read the files this feature touches — not just filenames.
   - Run `git status --short` / `git diff --name-status` when the feature relates to in-progress work.
   - If the feature's scope or acceptance criteria are unclear, ask before generating tasks instead of guessing.

2. Break the feature into task-sized issues:
   - Each task is a small, independently implementable and reviewable unit (roughly one PR's worth of work).
   - Split by natural implementation layers/scopes: data model/schema, backend/API, frontend/UI, integration, tests, docs, config/infra — include only those the feature actually needs.
   - Order tasks by dependency (e.g. schema before API before UI) and note prerequisites.
   - Keep tasks within the feature's scope; surface anything outside it as "out of scope" rather than inventing new features.

3. Write each task as copy-ready Markdown:
   - Output each task issue in its own fenced code block so the user can copy it directly.
   - Use a clear, scoped title: `type(scope): summary` (e.g. `feat(auth-api): add token refresh endpoint`).
   - Include these sections in the body:
     - `## Parent feature` — link/reference to the feature issue this task belongs to.
     - `## Summary` — what this task does and why, in plain language.
     - `## Context` — relevant files/paths (`path:line` when useful) and current behavior.
     - `## Steps` — a checklist (`- [ ]`) of concrete implementation steps.
     - `## Acceptance criteria` — how to know this task is done.
   - Add optional sections only when relevant: `## Depends on`, `## Out of scope`, `## Labels`.
   - Mark anything uncertain as "needs verification" rather than guessing.

4. Output copy-ready Markdown only — never create issues:
   - Only produce Markdown for the user to copy into their tracker.
   - Do not run `gh issue create`, push, or otherwise create issues remotely, even if asked — this skill is copy-only.

5. Summarize at the end:
   - List the task issues you generated, ordered by dependency.
   - Show the dependency chain briefly, and note anything left out of scope or needing the user's input.

## Task issue example

````text
```markdown
# feat(auth-api): add token refresh endpoint

## Parent feature
#123 — Keep users signed in with token refresh

## Summary
Add a refresh endpoint so the client can exchange a valid refresh token for a
new access token without re-authenticating.

## Context
- `routes/auth.py` — has login/logout, no refresh route.
- `services/auth.py:42` — `verify()` validates signature but not refresh.

## Steps
- [ ] Add `POST /auth/refresh` route
- [ ] Issue a new access token for a valid refresh token
- [ ] Rotate and invalidate the used refresh token

## Acceptance criteria
- A valid refresh token returns a new access token.
- Expired or reused refresh tokens are rejected.

## Depends on
- #124 (refresh token storage/schema)

## Labels
backend, auth, task
```
````
