# Contract: obsidian.elaborate

Purpose: Enrich the selected note using additional input and context from linked notes.

## Inputs
- selected_path: string
- additions: string (free-form)

## Behavior
- Read selected note and linked notes
- Propose structured additions per template sections
- Preserve user intent; avoid overwrites

## Outputs
- dry_run_diff: string
- sections_updated: array<string>

## Errors
- note_not_found
- template_mismatch
- merge_conflict
