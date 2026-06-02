---
name: commit-workflow
description: Use when creating git commits, rewriting or splitting commits, staging changes, or writing commit messages. Requires Codex to inspect every changed file before staging, split commits by logical scope, avoid lump commits, and write scoped English conventional commit messages.
---

# Commit Workflow

Use this skill whenever the user asks to create one or more git commits.

- **Only commit when the user explicitly asks.** Do not commit proactively after making changes.
- **Commit messages stay in English** (conventional `type(scope): summary`), regardless of the chat language.

## Required workflow

1. Inspect the working tree and files before staging:
   - Run `git status --short`.
   - Enumerate changed and untracked files with `rg --files`, `git diff --name-status`, `git show --name-status`, or targeted directory listing as appropriate.
   - Read every changed file that may be committed, either through `git diff`, `git diff --cached`, `git show`, targeted file reads, or file metadata tools for binary assets.
   - For untracked directories, inspect the file list and read representative source/config/docs/templates before staging.
   - Identify which changes belong to the user's request and which appear unrelated.
   - Do not stage or commit based only on filenames.

2. Split commits by scope:
   - Group changes by logical scope such as package, app, feature area, model/schema, UI/view, config, docs, tests, database, or chore.
   - Create separate commits for each distinct scope, even when the user asks to "commit everything".
   - Avoid lump commits for newly added projects or large directories; split scaffold, model/schema, UI/view, data/SQL, tests, docs, and tooling when those scopes are present.
   - Do not mix unrelated user changes into the same commit.
   - Leave unrelated existing changes unstaged unless the user explicitly asks to include them.
   - If a prior commit was too broad and the user asks to fix it, reset or rewrite it into scoped commits after inspecting the files again.

3. Stage deliberately:
   - Stage only the files or hunks that belong to the current scope.
   - Re-check `git diff --cached --stat` and the cached diff before each commit.

4. Write commit messages in English:
   - Both the commit header and body must be English.
   - Always use a concise conventional-style header with an explicit scope:
     `type(scope): summary`
   - Choose a clear scope that matches the changed area.
   - Do not create unscoped headers such as `type: summary`.
   - Add a body when it helps explain why the change was made, notable behavior, or migration/setup impact.

5. Verify after committing:
   - Show the new commit hash and header.
   - Run `git status --short`.
   - Tell the user about any remaining uncommitted changes.

## Commit message examples

```text
chore(config): add Django project dependencies

Group web, database, auth, API documentation, and test dependencies in
pyproject.toml for the Django development environment.
```

```text
chore(workspace): remove placeholder file

Remove .gitkeep now that the workspace directory contains tracked project files.
```