# Prompt: obsidian.plan

Purpose: Plan from an Idea (or Goal) into a structured Project note.

Supported in this version:
- Idea → Project (Goal → Project and Project → Activity Plan are planned next)

Inputs:
- selected_path: string path to the source note (absolute or relative to the Vault root)

Behavior:
- Creates a Project note using `.obsidian/templates/project.v1.md`
- Placement: `Vault/2) Projects/<slug>.md`
- Links back to the Idea via its title in frontmatter: `links.idea: [[<Idea Title>]]`
- Idempotent: re-running won’t duplicate; updates only when content changes
- Safety: dry-run by default; use `-Approve` to apply

Usage (Windows PowerShell):

Dry-run (preview changes only):

		powershell -NoProfile -ExecutionPolicy Bypass -File \
			".obsidian/scripts/powershell/obsidian.plan.ps1" \
			-SelectedPath "Vault/0) Ideas/us1-test-idea.md"

Apply (write changes):

		powershell -NoProfile -ExecutionPolicy Bypass -File \
			".obsidian/scripts/powershell/obsidian.plan.ps1" \
			-SelectedPath "Vault/0) Ideas/us1-test-idea.md" -Approve

Notes:
- `selected_path` accepts absolute paths or Vault-relative paths like `Vault\0) Ideas\...`
- Trace logs are written to `.agent/logs/*.json` and include the diff, inputs, and target path.
- If the Project already exists and matches the new content, the script prints `No changes`.
