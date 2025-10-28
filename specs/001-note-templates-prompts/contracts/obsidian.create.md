# Contract: obsidian.create

Purpose: Create a note of a given type using the appropriate template, placing it in the correct vault folder, with required frontmatter.

## Inputs
- type: enum {idea, goal, project, area, plan} (optional; if omitted, infer, then confirm)
- title: string
- description: string (optional)

## Behavior
- Read constitution rules, validate type and placement
- Generate id (slug-hash6) and filename (sanitized)
- Place note in folder by type (Idea→Reference/Ideas, Project→Projects, etc.)
- Populate general + type-specific frontmatter
- Suggest links to related notes

## Outputs
- created_path: string (relative to vault)
- dry_run_diff: string (if dry-run)
- links_added: array<string>

## Errors
- ambiguous_type
- duplicate_note
- invalid_filename
- missing_vault
