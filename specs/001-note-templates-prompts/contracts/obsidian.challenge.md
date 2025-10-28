# Contract: obsidian.challenge

Purpose: Critically review the selected note and surface gaps, risks, and counter-assumptions.

## Inputs
- selected_path: string

## Behavior
- Analyze selected note and linked notes
- Produce structured critique and improvement suggestions

## Outputs
- critique: array<string>
- suggestions: array<string>

## Errors
- note_not_found
- template_mismatch
