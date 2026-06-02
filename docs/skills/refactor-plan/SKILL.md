---
name: refactor-plan
description: Use when the user wants to plan a refactor without changing behavior. Requires Codex to read the target code and its callers/tests first, identify concrete problems, and output a step-by-step refactor plan broken into small, independently shippable, behavior-preserving steps — making no code changes unless explicitly asked afterward.
---

# Refactor Plan

Use this skill whenever the user asks how to refactor or clean up code. This produces a plan, not edits.

- **Read-only: do not change code.** Output the plan only; edit only if the user explicitly asks afterward.
- **Write the plan in the user's language** (default Korean if unclear).

## Required workflow

1. Read before planning:
   - Read the target code fully, plus its callers, tests, and anything that depends on its public surface.
   - Note the current behavior and the existing test coverage (a refactor must preserve behavior).
   - Identify the real problems: duplication, oversized units, tangled responsibilities, leaky abstractions, hard-to-test code, naming.
   - Do not guess; mark unverified assumptions as "needs verification".

2. Define scope and safety:
   - State explicitly what behavior must stay identical (the public contract, outputs, side effects).
   - Call out missing tests that should exist before refactoring, as a characterization-test step.
   - Keep the refactor within scope; do not fold in feature changes or bug fixes (note them separately).

3. Break it into small steps:
   - Order steps so each one is independently shippable and reviewable (roughly one PR each), keeping the code green between steps.
   - For each step give: goal, files/areas touched, the transformation, how behavior is preserved, and how to verify (tests/checks).
   - Sequence to minimize risk (e.g. add tests → extract → rename → move → delete dead code).

4. Do not change code by default:
   - Output the plan only. Make edits solely when the user explicitly asks afterward.

## Output format

```markdown
# Refactor plan: <target>

## Goal & scope
- What improves, and what behavior must stay identical.

## Risks & preconditions
- Missing tests to add first, risky areas, dependencies.

## Steps
1. <step> — files: `path`; change: ...; behavior preserved by: ...; verify: ...
2. ...

## Out of scope
- Bugs/features noticed but deliberately not included.
```
