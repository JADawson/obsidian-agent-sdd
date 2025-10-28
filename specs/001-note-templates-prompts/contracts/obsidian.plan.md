# Contract: obsidian.plan

Purpose: Transform an Idea or Goal into a Project, or advance a Project to an Activity Plan.

## Inputs
- selected_path: string

## Behavior
- For Idea→Project: create Project, link back to Idea
- For Goal→Project: create Project, link to Goal
 - For Project→Activity Plan: create plan under `2) Projects/<Project>/Activity Plans`

## Outputs
- created_paths: array<string>
- dry_run_diff: string
- links_added: array<string>

## Errors
- note_not_found
- invalid_transition
- duplicate_note
