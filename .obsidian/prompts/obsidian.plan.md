# Prompt: obsidian.plan

Purpose: Transform an Idea or Goal into a Project, or advance a Project to an Activity Plan.

Inputs:
- selected_path: string

Behavior:
- Idea→Project: create Project with links back to Idea
- Goal→Project: create Project with link to Goal
- Project→Activity Plan: create plan under `2) Projects/<Project>/Activity Plans`
- Dry-run by default; require approval to write

Example:

> obsidian.plan selected_path="Vault/0) Ideas/My Idea.md"
