# Prompt: obsidian.challenge

Purpose: Critically review the selected Idea or Project and scaffold Risks, Assumptions, and Improvements sections.

Inputs:
- selected_path: string (absolute or Vault-relative)

Behavior (v1):
- Supports Idea and Project notes
- Ensures the following sections exist (append if missing):
	- Risks (bulleted list)
	- Assumptions (bulleted list)
	- Improvements (checkbox list)
- Updates frontmatter `updated: YYYY-MM-DD`
- Proposes a safe, idempotent diff (dry-run first)

Usage (Windows PowerShell):

Dry-run (preview changes only):

		powershell -NoProfile -ExecutionPolicy Bypass -File \
			".obsidian/scripts/powershell/obsidian.challenge.ps1" \
			-SelectedPath "Vault/2) Projects/us1-test-idea.md"

Apply (write changes):

		powershell -NoProfile -ExecutionPolicy Bypass -File \
			".obsidian/scripts/powershell/obsidian.challenge.ps1" \
			-SelectedPath "Vault/2) Projects/us1-test-idea.md" -Approve

Notes:
- Trace logs are written to `.agent/logs/*.json` including the diff.
- v1 avoids destructive edits; it only inserts missing sections.
