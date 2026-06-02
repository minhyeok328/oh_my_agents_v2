---
name: test-author
description: Use when the user asks to write or add tests for changed or existing code. Requires Codex to read the target code and the existing test setup first, follow the project's test framework and conventions, cover happy path, edge cases, and error handling, and add tests without changing the code under test unless explicitly asked.
---

# Test Author

Use this skill whenever the user asks to write tests. Pairs well with `frontend-qa` / `backend-qa`, which surface missing coverage.

- **This skill changes code: it adds test files**, but does not modify the code under test unless explicitly asked.
- **Write test names/comments in the user's language** (default Korean if unclear) only if it matches the project's existing convention; otherwise follow the repo.

## Required workflow

1. Read before writing tests:
   - Identify the code under test and read it fully (inputs, outputs, branches, side effects).
   - Detect the test framework and conventions already in use (test runner, file naming, folder layout, fixtures, mocks, assertion style).
   - When the task targets recent work, use `git diff --name-status` to find changed behavior that needs coverage.
   - Do not assume a framework — match what the repo uses. Mark unknowns as "needs verification".

2. Decide what to cover:
   - Happy path for the main behavior.
   - Edge cases: empty/null/boundary inputs, large inputs, unusual ordering.
   - Error handling: invalid input, failed dependencies, timeouts, thrown errors.
   - For changed code, prioritize the behavior that changed and any branch left untested.

3. Write tests that fit the project:
   - Follow existing naming, structure, and assertion patterns; place files where the project expects them.
   - Keep tests isolated and deterministic; mock external dependencies (network, DB, time, randomness) the way the repo already does.
   - One clear behavior per test; use descriptive test names.
   - Do not change the code under test unless the user explicitly asks (if a test reveals a bug, report it instead of silently fixing).

4. Verify and report:
   - Run the test suite when possible and report results; if it can't run, say why.
   - List what you covered, what you intentionally left out, and any behavior that looks buggy or untestable.

## Notes

- Prefer extending existing test files over creating parallel ones when conventions allow.
- Cover behavior, not implementation details, so tests survive refactors.
- If there is no test setup at all, propose a minimal one matching the stack before adding tests.
