# Data Model: Note Templates & Prompts

Date: 2025-10-28
Branch: 001-note-templates-prompts

## Entities

### General Frontmatter (all notes)
- id: string (slug-hash6, stable)
- type: enum {idea, goal, project, area, plan}
- status: enum {draft, active, done, archived}
- created: date (YYYY-MM-DD)
- updated: date (YYYY-MM-DD)
- tags: array<string> (must be subset of curated set)

### Idea
- problem: string
- context: string
- related_areas: array<string>
- candidate_projects: array<link>

### Goal
- outcome: string
- measurement: string
- timeframe: string
- related_areas: array<string>

### Project
- owner: string
- scope: string
- phases: array<string>
- status: enum {planned, in-progress, blocked, complete}
- links: { goal?: link, idea?: link }

### Area
- scope: string
- responsibilities: array<string>

### Activity Plan (per-project only)
- tasks: array<{ title: string, status: enum{todo, doing, done}, due?: date }>
- schedule: string
- dependencies: array<link>

## Relationships
- Idea → Project (derived)
- Goal → Project (targeting)
- Project ↔ Activity Plan (contains/derived)
- Area ↔ {Idea|Goal|Project} (linked by tag or field)

## Validation Rules
- tags ⊆ {#idea, #goal, #project, #area, #plan}
- id must remain immutable once assigned
- Activity Plan must be located under `2) Projects/<Project>/Activity Plans`
- Project must link back to source Idea and/or Goal when derived
