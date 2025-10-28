# Feature Specification: Note Templates & Prompts

**Feature Branch**: `001-note-templates-prompts`  
**Created**: 2025-10-28  
**Status**: Draft  
**Input**: User description: "Define initial Obsidian note types (Idea, Goal, Project, Area, Activity Plan) and agent prompts (create, elaborate, clarify, plan, challenge) with frontmatter rules and context reading."

## Clarifications

### Session 2025-10-28

- Q: Activity Plan structure and scope → A: Per-project only; store under `Projects/<Project>/Activity Plans`; required: `tasks[]`, `schedule`, `dependencies`.
- Q: Tag taxonomy boundaries → A: Strict curated list only: `{#idea, #goal, #project, #area, #plan}`.
- Q: Frontmatter id scheme → A: Hybrid `slug + short hash` (e.g., `project-abc123`).

## User Scenarios & Testing (mandatory)

### User Story 1 - Create an Idea note (Priority: P1)

User captures a new Idea using a single command. The agent chooses the correct
template, writes frontmatter, places the file under `0) Ideas/`, and
links to related notes if detected.

**Why this priority**: Low friction capture is foundational; Ideas feed Goals and
Projects.

**Independent Test**: Run `obsidian.create` with type `Idea` and a short
description; verify a single new Markdown file with correct structure and
placement is created.

**Acceptance Scenarios**:

1. Given no existing note with the same title, when the user runs
  `obsidian.create` with type `Idea`, then a new note is created in
  `0) Ideas/` with required general and type-specific frontmatter.
2. Given related notes exist, when creating the Idea, then the agent suggests or
   populates wiki links to those notes.

---

### User Story 2 - Plan from Idea to Project (Priority: P1)

User selects an Idea and asks the agent to plan next steps, producing a Project
note under `2) Projects/` with links back to the Idea and placeholders for phases
and activities.

**Why this priority**: Moving Ideas forward is core to value delivery.

**Independent Test**: Run `obsidian.plan` targeting an Idea; verify a new
Project note is created with required fields and cross-links.

**Acceptance Scenarios**:

1. Given an Idea note is selected, when the user runs `obsidian.plan`, then a
  Project note is created under `2) Projects/` with mapped fields, initialized
   phases, and links to the source Idea.
2. Given the Project file already exists, when planning runs again, then the
   script performs an idempotent update or produces a safe diff for approval.

---

### User Story 3 - Clarify a Project (Priority: P2)

User selects a Project and requests clarifications; the agent reads the note and
linked notes, asks targeted questions, and suggests concrete, actionable edits
without overwriting user intent.

**Why this priority**: Clarity increases execution success.

**Independent Test**: Run `obsidian.clarify` with a selected Project; verify a
dry-run diff highlighting proposed clarifications is produced for approval.

**Acceptance Scenarios**:

1. Given a Project with missing fields, when `obsidian.clarify` runs, then the
   agent outputs up to N targeted questions and a proposed diff filling required
   fields for user approval.
2. Given linked notes exist (Goal, Idea), when clarify runs, then it considers
   their content to reduce duplicate entry and improve accuracy.

### Edge Cases

- Ambiguous type when creating: agent cannot infer type from input → prompt for
  confirmation before write.
- Duplicate title/path: existing note found → present merge/diff; avoid
  overwriting without explicit approval.
- Invalid filename characters or excessively long titles on Windows → sanitize
  and normalize while preserving H1 and links.
- Missing vault path or insufficient permissions → fail with helpful message.
- Broken or circular links when generating references → validate and warn.

## Requirements (mandatory)

### Functional Requirements

- FR-001: Agent MUST create notes from versioned templates with required fields.
- FR-002: Agent MUST place notes in correct vault folders per constitution.
- FR-003: Agent MUST support dry‑run mode showing diffs for human approval (on
  by default in VS Code).
- FR-004: Agent MUST maintain links and tags according to template rules and
  update backlinks when creating derivative notes (Idea→Project, Goal→Project).
- FR-005: Scripts MUST operate only within the configured vault path.
- FR-006: Agent SHOULD read selected note and directly linked notes to derive
  context before proposing changes.
- FR-007: General frontmatter MUST include: `id`, `type`, `status`, `created`,
  `updated`, `tags`. The `id` MUST be a hybrid of a human‑readable slug and a
  short hash (e.g., `my-title-abc123`), remaining stable across renames.
- FR-008: Type-specific frontmatter MUST be enforced per template (see Key
  Entities).
- FR-009: Operations MUST be idempotent; re‑running on the same input yields a
  no‑op or a safe merge with explicit user approval.
- FR-010: On create, if type is not provided, the agent MAY infer from input but
  MUST confirm with the user before writing.
- FR-011: File naming MUST follow the constitution: `YYYY-MM-DD Title` when
  dated, else concise readable title.
- FR-012: The system MUST record traces (prompt, params, paths, diff) to
  `.agent/logs/` excluding sensitive content.

NEEDS CLARIFICATION (max 3):

<!-- none -->

Resolved:

- FR-013: Activity Plans are per-project only; stored under `2) Projects/<Project>/Activity Plans`; required frontmatter: `tasks` (array), `schedule`, `dependencies`.
- FR-014: Tags are strictly curated to `{#idea, #goal, #project, #area, #plan}`; agent MUST validate and reject non‑curated tags (with suggestion to map or remove).
- FR-015: Frontmatter `id` uses hybrid scheme `slug + short hash` (e.g., `note-title-abc123`); generation MUST be deterministic and collision‑resistant; `id` MUST persist once assigned.

### Key Entities (include if feature involves data)

- Note Type:
  - Idea (frontmatter: problem, context, related_areas, candidate_projects)
  - Goal (frontmatter: outcome, measurement, timeframe, related_areas)
  - Project (frontmatter: owner, scope, phases, status, links: goal, idea)
  - Area (frontmatter: scope, responsibilities)
  - Activity Plan (per-project only; folder: `Projects/<Project>/Activity Plans`; frontmatter: tasks[], schedule, dependencies)
  - All note types share general frontmatter including `id` in the format `slug-hash6`.

- Operation:
  - Create (obsidian.create): inputs: type?, title, description; outputs:
    new note; links; placement.
  - Elaborate (obsidian.elaborate): inputs: selected note, additional detail;
    outputs: enriched sections and fields.
  - Clarify (obsidian.clarify): inputs: selected note; outputs: targeted
    questions and proposed diffs.
  - Plan (obsidian.plan): inputs: selected Idea/Goal/Project; outputs:
    derivative note and/or structured plan content.
  - Challenge (obsidian.challenge): inputs: selected note; outputs: critique,
    risks, counter‑assumptions, and suggested improvements.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: Create Idea from input to committed file in ≤ 30 seconds (median).
- SC-002: ≥ 90% of new Idea/Project notes contain all required general
  frontmatter fields without manual edits.
- SC-003: 100% of write operations default to dry‑run with human approval in VS
  Code.
- SC-004: Re‑running an operation on the same note produces no unintended
  duplication (idempotency verified in audit).

