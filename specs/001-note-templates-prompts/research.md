# Research: Note Templates & Prompts

Date: 2025-10-28
Branch: 001-note-templates-prompts

## Decisions (confirmed)

- Activity Plans: Per-project only; folder `Projects/<Project>/Activity Plans`; frontmatter: tasks[], schedule, dependencies.
- Tags: Strict curated set `{#idea, #goal, #project, #area, #plan}`; agent validates and rejects others with map/remove suggestions.
- ID Scheme: Hybrid `slug + short hash` (e.g., `note-title-abc123`); deterministic, collision-resistant, persistent across renames.

## Unknowns to confirm

- Staging/Test Vault Path (separate from Virtual Vault)

## Best practices for this domain

- Use templates to encode required frontmatter and sections; version them.
- Idempotent scripts: detect existing notes; propose diffs instead of overwrite.
- Human-in-the-loop: dry-run diffs reviewed in VS Code before any write.
- Tracing: log prompt, params, paths, diffs to `.agent/logs/`.
- Placement rules: enforce per note type (Idea→`0) Ideas/`, Project→`2) Projects/`).

## Alternatives considered

- ID Scheme alternatives: UUID v4 (rejected: unreadable), human slug only (rejected: collisions).
- Tags governance: open tagging (rejected: sprawl), namespaced custom (rejected for initial simplicity).
