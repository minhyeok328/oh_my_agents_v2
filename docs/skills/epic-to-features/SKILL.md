---
name: epic-to-features
description: Use when the user provides an epic in an epic/feature/task hierarchy and wants its child feature issues generated. Requires Codex to read the epic and the relevant workspace code first, break the epic into independently shippable feature issues, and output copy-ready Markdown feature issues that link back to the parent epic. Output Markdown only — never create issues remotely.
---

# Epic → Features

Use this skill whenever the user shows an epic and asks to generate its child feature issues. The hierarchy is **epic → feature → task**: the input is one epic, the output is the set of features needed to deliver it. (Use the `feature-to-tasks` skill to break each feature down further.)

- **Copy-only: do not change code or create issues remotely.**
- **Write the issues in the user's language** (default Korean if unclear); keep the `feat(scope): summary` title and code identifiers as-is.

## Required workflow

1. Read the epic and the code before splitting:
   - Parse the epic: its goal, scope, success criteria, and constraints.
   - List the folder structure (e.g. `git ls-files`, directory listing, or glob) and read the areas the epic touches — not just filenames.
   - If the epic's goal or scope is unclear, ask before generating features instead of guessing.

2. Break the epic into feature-sized issues:
   - Each feature is an independently shippable slice of user-facing or system value (bigger than a task, smaller than the epic).
   - Split by capability/user outcome, not by code layer (layers belong to tasks).
   - Order features by dependency and priority; note prerequisites and a sensible delivery sequence.
   - Keep features within the epic's scope; surface anything outside it as "out of scope" rather than inventing new epics.

3. Write each feature as copy-ready Markdown:
   - Output each feature issue in its own fenced code block so the user can copy it directly.
   - Use a clear, scoped title: `feat(scope): summary` (e.g. `feat(auth): keep users signed in with token refresh`).
   - Include these sections in the body:
     - `## Parent epic` — link/reference to the epic this feature belongs to.
     - `## Summary` — the user value and why it matters, in plain language.
     - `## Scope` — what's included (and explicitly what's not).
     - `## Acceptance criteria` — how to know the feature is done.
     - `## Suggested tasks` — a checklist (`- [ ]`) hinting at the breakdown (full split via `feature-to-tasks`).
   - Add optional sections only when relevant: `## Depends on`, `## Out of scope`, `## Labels`.
   - Mark anything uncertain as "needs verification" rather than guessing.

4. Output copy-ready Markdown only — never create issues:
   - Only produce Markdown for the user to copy into their tracker.
   - Do not run `gh issue create`, push, or otherwise create issues remotely, even if asked — this skill is copy-only.

5. Summarize at the end:
   - List the feature issues you generated, ordered by dependency/priority.
   - Show the delivery sequence briefly, and note anything left out of scope or needing the user's input.

## Feature issue example

````text
```markdown
# feat(auth): keep users signed in with token refresh

## Parent epic
#100 — Authentication & session management

## Summary
Users get logged out abruptly when access tokens expire. Add a refresh
mechanism so sessions persist seamlessly without re-authentication.

## Scope
- Refresh tokens issued at login and exchanged for new access tokens.
- Token rotation and revocation.
- Not included: social login, MFA.

## Acceptance criteria
- A valid session is silently kept alive past access-token expiry.
- Expired or reused refresh tokens are rejected.

## Suggested tasks
- [ ] Refresh token storage/schema
- [ ] Refresh endpoint (issue + rotate)
- [ ] Client auto-refresh on 401

## Depends on
- #99 (auth service baseline)

## Labels
backend, auth, feature
```
````
