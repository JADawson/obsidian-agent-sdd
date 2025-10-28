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

## Usage (conceptual)
- Use Copilot slash commands or run scripts directly with dry-run by default.
- Select a note in VS Code when using context-sensitive prompts.
- For development, operate against the Virtual Vault at `./Vault`.

## Safety and Idempotency
- Dry-run by default; human approval required before writes.
- Operations are idempotent and log traces to .agent/logs.
