# Prompt: obsidian.clarify

Purpose: Ask targeted questions and propose clarifying edits for the selected Project note.

Inputs:
- selected_path: string (absolute or Vault-relative)

Behavior (v1):
- Supports Project notes (type: project) only
- Reads the note’s frontmatter and applies rules from the spec:
	- Status must be one of: planned, active, paused, completed, cancelled
	- Primary upstream context: Goal > Idea (fallback to Idea if no Goal)
	- Ownership via Area is required: frontmatter `links.area`
- Produces up to 5 targeted questions and a proposed diff
- Dry-run by default; use `-Approve` to apply

Usage (Windows PowerShell):

Dry-run (preview changes only):

		powershell -NoProfile -ExecutionPolicy Bypass -File \
			".obsidian/scripts/powershell/obsidian.clarify.ps1" \
			-SelectedPath "Vault/2) Projects/us1-test-idea.md"

Apply (write changes):

		powershell -NoProfile -ExecutionPolicy Bypass -File \
			".obsidian/scripts/powershell/obsidian.clarify.ps1" \
			-SelectedPath "Vault/2) Projects/us1-test-idea.md" -Approve

Notes:
- Writes a trace to `.agent/logs/*.json` including the diff and question list.
- In v1, linked notes (Goal/Idea/Area) aren’t auto-discovered; provide them via edits or answer the questions and re-run.
