# Prompt: obsidian.elaborate

Purpose: Enrich the selected Idea or Project by inserting missing template sections and prompting for concise details.

Inputs:
- selected_path: string (absolute or Vault-relative)

Behavior (v1):
- Supports Idea and Project notes
- Ensures required sections exist based on the template/spec
	- Idea: Problem, Context, Related Areas, Candidate Projects
	- Project: Scope, Phases
- Updates frontmatter `updated: YYYY-MM-DD`
- Produces up to 5 short questions (suggested answers) and a proposed diff
- Dry-run by default; use `-Approve` to apply

Usage (Windows PowerShell):

Dry-run (preview changes only):

		powershell -NoProfile -ExecutionPolicy Bypass -File \
			".obsidian/scripts/powershell/obsidian.elaborate.ps1" \
			-SelectedPath "Vault/0) Ideas/us1-test-idea.md"

Apply (write changes):

		powershell -NoProfile -ExecutionPolicy Bypass -File \
			".obsidian/scripts/powershell/obsidian.elaborate.ps1" \
			-SelectedPath "Vault/0) Ideas/us1-test-idea.md" -Approve

Notes:
- Trace logs are written to `.agent/logs/*.json` including the diff and questions.
- v1 does not auto-discover linked notes; answer prompts and re-run to progressively fill content.
