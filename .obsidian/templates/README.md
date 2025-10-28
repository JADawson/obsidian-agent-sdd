# Templates Guide

This folder contains the authoritative Markdown templates used by the Obsidian Agent scripts.

- idea.v1.md — Capture new Ideas with curated tag #idea
- goal.v1.md — Define Goals
- project.v1.md — Standard Project template
- area.v1.md — Define Areas (ownership)
- activity-plan.v1.md — Per-project Activity Plans

## Placeholders and auto-fill

The scripts replace these placeholders when creating notes:

- <id> — slug+hash identifier, e.g., slug-hash6
- <Title> — note title
- <YYYY-MM-DD> — current date (UTC-local date)
- [[<Idea Note>]] — linked Idea title (for project.v1)

## Required frontmatter and conventions

- type: one of idea | goal | project | area | plan
- status (for projects): planned | active | paused | completed | cancelled
- tags: curated per note type (e.g., #idea for Ideas; #project for Projects)
- links: block containing cross-links
  - For Projects, links.area must be present and point to the owning Area: [[<Owning Area>]]
- Ownership section (in body, Project template):
  - Owning Area: [[<Area>]]
  - Collaborators: free-form

## Filenames and placement

- Filenames are slug-only (no hash) and sanitized for filesystem safety
- Placement follows numbered vault folders per constitution:
  - Ideas → 0) Ideas/
  - Goals → 1) Goals/
  - Projects → 2) Projects/
  - Areas → 3) Areas/
  - Reference → 4) Reference/
  - Archive → 5) Archive/

## Versioning

- Template versions use the suffix .v1.md, .v2.md, etc.
- When migrating, scripts should target the newest version; older notes may retain historical versions.

