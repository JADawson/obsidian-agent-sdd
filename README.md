# Obsidian Agent SDD

An agentic workflow for Obsidian + VS Code + Copilot. This repository provides versioned templates, prompts, and safe PowerShell scripts to create and transform structured notes in a Virtual Vault.

Current status (feature branch `001-note-templates-prompts`):
- Implemented: Idea creation (US1) with `obsidian.create.ps1`
- Implemented: Plan Idea → Project (US2) with `obsidian.plan.ps1`
- Up next: Clarify/refine flow (US3)

## Project structure

- `Vault/` — Virtual Vault for development/testing
	- `0) Ideas/`
	- `1) Goals/`
	- `2) Projects/`
	- `3) Areas/`
	- `4) Reference/`
	- `5) Archive/`
- `.obsidian/` — Project-owned assets
	- `templates/` — Markdown templates: idea, goal, project, area, activity-plan
	- `prompts/` — Prompts used by the agent workflows (documented usage)
	- `scripts/powershell/` — PowerShell helpers and scripts (dry-run + idempotent)
- `.agent/logs/` — Operation traces and diffs (ignored by git)
- `specs/001-note-templates-prompts/` — Spec, plan, data model, tasks, quickstart

The Vault uses a numbered top-level structure for predictable sorting, per the project constitution.

## Quickstart

Prerequisites:
- Windows with PowerShell 5.1+ (or PowerShell 7)
- VS Code (optional but recommended)

One-session script execution (optional):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Create an Idea (dry-run, then apply):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".obsidian/scripts/powershell/obsidian.create.ps1" -Type idea -Title "US1 Test Idea"
powershell -NoProfile -ExecutionPolicy Bypass -File ".obsidian/scripts/powershell/obsidian.create.ps1" -Type idea -Title "US1 Test Idea" -Approve
```

Plan from Idea → Project (dry-run, then apply):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".obsidian/scripts/powershell/obsidian.plan.ps1" -SelectedPath "Vault/0) Ideas/us1-test-idea.md"
powershell -NoProfile -ExecutionPolicy Bypass -File ".obsidian/scripts/powershell/obsidian.plan.ps1" -SelectedPath "Vault/0) Ideas/us1-test-idea.md" -Approve
```

## Safety and idempotency

- Dry-run by default; use `-Approve` to apply changes
- Scripts are vault-safe and idempotent: re-running won’t duplicate content
- All operations write trace logs to `.agent/logs/*.json` with the diff and inputs

## Configuration

Scripts read `.obsidian/config.json` to resolve the vault root and placement folders. See `specs/001-note-templates-prompts/quickstart.md` for a sample config and more details.

## Documentation

- Quickstart: `specs/001-note-templates-prompts/quickstart.md`
- Feature spec: `specs/001-note-templates-prompts/spec.md`
- Tasks (status): `specs/001-note-templates-prompts/tasks.md`
- Plan prompt guide: `.obsidian/prompts/obsidian.plan.md`

## Development notes

- Use the Virtual Vault in `Vault/` for local testing
- Keep operational assets in `.obsidian/`; traces in `.agent/logs/`
- Contributions should align with the numbered Vault structure and template-driven flows
