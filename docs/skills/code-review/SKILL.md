---
name: code-review
description: Use when reviewing code changes, a diff, a pull request, or a branch with a code-review mindset. Requires Codex to prioritize bugs, behavioral regressions, security issues, and missing tests, report findings ordered by severity, and avoid making code changes unless the user explicitly asks.
---

# Code Review

Use this skill whenever the user asks to review code, a diff, a pull request, or a branch.

- **Read-only: do not change code.** Propose fixes in words only.
- **Write the report in the user's language** (default Korean if unclear). Keep code identifiers and paths as-is.
- **When to use a different skill:** for a security-only deep dive use `security-audit`; for a whole-codebase quality sweep use `frontend-qa` / `backend-qa`. Use this skill for a focused review of specific changes.

## Required workflow

1. Establish the review scope before reading:
   - Determine what to review: working tree changes, staged changes, a branch range, or specific files the user named.
   - Run `git status --short` and `git diff --name-status` (or `git diff --name-status <base>...<head>`) to enumerate changed files.
   - Read every changed file and enough surrounding context (callers, callees, tests, config) to judge behavior, not just the diff lines.
   - Do not review based on filenames or diff stats alone.

2. Prioritize what matters:
   - Focus first on bugs, behavioral regressions, security issues, and missing or inadequate tests.
   - Then consider correctness edge cases, error handling, concurrency/race conditions, data integrity, and performance.
   - Treat style, naming, and formatting as low priority unless they cause real confusion or hide a defect.

3. Make findings the primary output, ordered by severity:
   - Lead with the highest-severity issues; order the whole report by severity.
   - For each finding include: severity, location (`path:line`), what is wrong, why it matters (the concrete failure or risk), and a suggested fix or direction.
   - Tie claims to specific code; do not speculate. Mark anything uncertain as "needs verification" and say what to check.
   - Call out missing test coverage for changed behavior explicitly as findings.

4. Do not change code:
   - Do not edit, refactor, or auto-format files during review.
   - Only propose changes in the report. Make edits solely when the user explicitly asks for them afterward.

5. Summarize at the end:
   - Give a short overall assessment (e.g. safe to merge, needs changes, blockers present).
   - List the top blocking issues, then non-blocking suggestions.
   - State what could not be fully assessed and why.

## Severity guide

- `Critical`: data loss, security vulnerability, crash, or incorrect results in common paths.
- `High`: regression or bug likely to hit users, or missing tests for risky new behavior.
- `Medium`: edge-case bug, weak error handling, or maintainability risk with real impact.
- `Low`: minor concerns, style, or optional polish.

## Finding example

```text
[High] services/auth.py:42 — Token expiry is never checked
Expired tokens are accepted because `verify()` only validates the signature,
not `exp`. This lets revoked sessions stay valid. Add an expiry check and a
test covering an expired token.
```
