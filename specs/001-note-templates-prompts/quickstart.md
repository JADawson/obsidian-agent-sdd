# Quickstart: Note Templates & Prompts

This feature adds templates, prompts, and scripts to work with an Obsidian vault via VS Code + Copilot.

## Prerequisites
- Windows with PowerShell 5.1+ (or PowerShell 7)
- VS Code with GitHub Copilot
- Execution policy: allow scripts in current session only

```powershell
# In this terminal session only
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## Structure
- Vault/ (Virtual Vault for development/testing)
	- 0) Ideas/
	- 1) Goals/
	- 2) Projects/
	- 3) Areas/
	- 4) Reference/
	- 5) Archive/
- .obsidian/templates/ (Idea, Goal, Project, Area, Activity Plan)
- .obsidian/prompts/ (obsidian.create, obsidian.elaborate, obsidian.clarify, obsidian.plan, obsidian.challenge)
- .obsidian/scripts/powershell/ (create + helpers)
- .agent/logs/ (traces, diffs)

## Configuration
- Configure absolute vault path and folder mapping in `.obsidian/config.json`:

```
{
	"vaultPath": "C:\\Local Dev\\obsidian-agent\\Vault",
	"folders": {
		"idea": "0) Ideas",
		"goal": "1) Goals",
		"project": "2) Projects",
		"area": "3) Areas",
		"reference": "4) Reference",
		"archive": "5) Archive"
	},
	"id": { "hashLength": 6, "separator": "-" },
	"safety": { "dryRunByDefault": true, "requireApproval": true, "vaultBoundary": true }
}
```

Scripts read this file to resolve vault-safe paths and placement rules.

## Usage (conceptual)
- Use Copilot slash commands or run scripts directly with dry-run by default.
- Select a note in VS Code when using context-sensitive prompts.
- For development, operate against the Virtual Vault at `./Vault`.

## Safety and Idempotency
- Dry-run by default; human approval required before writes.
- Operations are idempotent and log traces to .agent/logs.

## Try it

1) Create an Idea (dry-run then apply):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".obsidian/scripts/powershell/obsidian.create.ps1" -Type idea -Title "US1 Test Idea"
powershell -NoProfile -ExecutionPolicy Bypass -File ".obsidian/scripts/powershell/obsidian.create.ps1" -Type idea -Title "US1 Test Idea" -Approve
```

2) Plan from Idea → Project (dry-run then apply):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".obsidian/scripts/powershell/obsidian.plan.ps1" -SelectedPath "Vault/0) Ideas/us1-test-idea.md"
powershell -NoProfile -ExecutionPolicy Bypass -File ".obsidian/scripts/powershell/obsidian.plan.ps1" -SelectedPath "Vault/0) Ideas/us1-test-idea.md" -Approve
```
