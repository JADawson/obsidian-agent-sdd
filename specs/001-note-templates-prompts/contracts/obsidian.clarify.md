# Contract: obsidian.clarify

Purpose: Ask targeted questions and propose clarifying edits for the selected note.

## Inputs
- selected_path: string

## Behavior
- Analyze selected note and linked notes
- Generate up to N questions and proposed edits

## Outputs
- questions: array<string>
- dry_run_diff: string

## Errors
- note_not_found
- template_mismatch
