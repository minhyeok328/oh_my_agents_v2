# Workspaces

`workspaces/` contains the real app repositories that Codex may work on.
The `oh_my_agents_v2` root stays as the governance control plane for rules, templates, contracts, and coordination docs.

Compared with the original `secret_agents` shell, v2 expects each app workspace to participate in a stricter operating model: one active workspace, an app-local profile, contract-first coordination, explicit verification commands, and Git Steward separation.

Declare exactly one active workspace before app-scoped implementation:

```text
Active workspace: workspaces/<app-slug>
```

Each app workspace should provide a profile at:

```text
workspaces/<app-slug>/.agent/profile.md
```

Each app workspace may also provide a machine-readable manifest at:

```text
workspaces/<app-slug>/.agent/manifest.yml
```

Use `docs/templates/WORKSPACE_PROFILE.template.md` when creating that profile.
The profile should define allowed write scopes, forbidden paths, verification commands, contract locations, and Git pointer metadata.
The `profile.md is authoritative` for app-local execution context.
An `app-local AGENTS.md is optional`; create one only when the app needs stable local agent guidance beyond the profile.

Use `.agent/manifest.yml` for the small set of values that validators must parse reliably: active root, profile path, contract root, verification command, Git mode, and secret-file policy. Keep explanations and judgment-heavy notes in `profile.md`.

`workspaces/sample-app` is a tracked fixture used by the repository validators. Treat it as test data for governance checks, not as a production app template to copy blindly.

## Workspace Rules

- Do not read or modify another `workspaces/*` app unless the user explicitly approves it.
- Do not read or commit real `.env`, `.env.local`, credentials, local databases, generated secrets, or `.git/**`.
- Keep implementation changes inside the active workspace and assigned write scope.
- Use a compact subagent task card when delegation is explicitly requested.
- Subagent task cards should include an owned outcome and checkpoint expectations; checkpoints are not forced timeouts while meaningful progress is visible.
- Implementation agents do not run Git commands.
- Commit, branch, push, and PR work must be handled by a Git Steward using `commit-workflow`.

## Setup Checklist

1. Place or clone the app repository under `workspaces/<app-slug>/`.
2. Create `workspaces/<app-slug>/.agent/profile.md`.
3. Declare `Active workspace: workspaces/<app-slug>` in the task request.
4. Confirm verification commands before implementation starts.
5. Assign Git Steward work separately if a commit, branch, push, or PR is needed.
