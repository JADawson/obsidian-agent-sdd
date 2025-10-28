# Obsidian Agent SDD Constitution

<!--
Sync Impact Report
Version change: 0.3.0 → 0.4.0
Modified principles:
- [PRINCIPLE_1_NAME] → Markdown‑First, Vault‑Native
- [PRINCIPLE_2_NAME] → Template‑Driven, Prompt‑Oriented
- [PRINCIPLE_3_NAME] → Deterministic & Idempotent Agents
- [PRINCIPLE_4_NAME] → Traceability & Human Review
- [PRINCIPLE_5_NAME] → Safety & Least Privilege
Added principles:
- Separation of Spec‑Kit Assets → Non‑destructive Fork under .obsidian/
Added sections:
- Vault Structure & Content Standards
- Development Workflow & Quality Gates
Removed sections:
- None
Templates requiring updates:
- .specify/templates/plan-template.md ✅ updated (added Obsidian Agent context + .obsidian paths)
- .specify/templates/spec-template.md ✅ updated (FRs for vault workflows)
- .specify/templates/tasks-template.md ✅ updated (agent paths + tasks examples)
- .specify/templates/agent-file-template.md ✅ updated (section names)
Follow-up TODOs:
- TODO(RATIFICATION_DATE): original adoption date unknown
- Add initial Obsidian templates for Idea and Project note types
- Add agent prompts: obsidian.create.idea, obsidian.create.project, obsidian.elaborate, obsidian.clarify, obsidian.challenge
- Add PowerShell scripts to operate within a vault folder (create, update, dry‑run)
 - Migrate project prompts to `.obsidian/prompts/`; exclude original `.github/` via .gitignore
-->

## Core Principles

### Markdown‑First, Vault‑Native
All outputs MUST be Obsidian‑compatible Markdown stored inside the configured
vault. Notes MUST use standard Obsidian conventions: YAML frontmatter when
needed, wiki links [[Like This]] for intra‑vault references, and tags using
`#tag` syntax. Agents MUST avoid binary outputs and external state unless
explicitly requested. Generated content MUST be readable without plugins.
Rationale: ensures portability, longevity, and direct usability in Obsidian.

### Template‑Driven, Prompt‑Oriented
Every note type (e.g., Idea, Project) MUST have a versioned Markdown template
and a companion agent prompt. Creation and update flows MUST reference these by
id/version. Templates MUST define structure, required fields, and link
conventions. Prompt text MUST be treated as source and versioned. Changes to
templates/prompts REQUIRE a version bump and migration guidance.

### Deterministic & Idempotent Agents
Given the same inputs and vault state, agent runs SHOULD produce the same
outputs. Scripts MUST be idempotent: creating a note that already exists MUST
result in a no‑op or a safe, explicit merge path. All create/update commands
MUST support a dry‑run mode that shows intended changes without writing.
Rationale: prevents duplication, drift, and accidental overwrites.

### Traceability & Human Review
Every operation MUST produce a trace including: prompt used, parameters,
target paths, and diff of proposed changes. Human‑in‑the‑loop approval is
REQUIRED before writes by default when run inside VS Code. Commits MUST use
structured messages referencing the operation (e.g., `obsidian.create.project:`)
and affected notes.

### Safety & Least Privilege
PowerShell scripts MUST operate only within the configured vault directory and
MUST not perform network calls or destructive operations without explicit
opt‑in flags. Backups or undo plans MUST exist for any batch change. A
configurable "test vault" path SHOULD be available for rehearsals.

### Separation of Spec‑Kit Assets (Non‑Destructive Fork)
The original `.specify/templates` and `.specify/scripts/powershell` directories
MUST remain intact as reference guides. This project MUST create its own
operational assets under `.obsidian/templates` (for note templates) and
`.obsidian/scripts/powershell` (for scripts). Prompts that belong to this
project MUST reside under `.obsidian/prompts/`. The original `.github/prompts`
are considered reference only. Changes and versioning apply to
these `.obsidian/` assets; reference materials in `.specify/` MUST NOT be
modified by default. Where feasible, `.specify/` and the original `.github/`
SHOULD be excluded from version control via `.gitignore`.

## Vault Structure & Content Standards

- Default structure (numbered for stable sorting): `0) Ideas/`, `1) Goals/`, `2) Projects/`, `3) Areas/`, `4) Reference/`, `5) Archive/`.
- Placement rules:
	- Idea notes default to `0) Ideas/` unless immediately promoted or linked into a Project.
	- Goal notes live in `1) Goals/`.
	- Project notes live in `2) Projects/` with subfolders as needed.
	- Area notes live in `3) Areas/`.
	- General reference materials live in `4) Reference/`.
	- Archived notes move to `5) Archive/` via explicit workflows.
- Naming: `YYYY-MM-DD Title` for dated notes; otherwise concise kebab or
	space‑separated titles. Filenames SHOULD match H1 titles.
- Frontmatter: use `type: idea|project|goal|area|plan`, `status`, `created`, `updated`, and
	stable identifiers when appropriate.
- Linking: prefer `[[Note Title]]`. Use relative links; avoid absolute paths.
- Tags: define a small, curated set (e.g., `#idea`, `#project`, `#area`, `#goal`, `#plan`).
- Templates MUST declare required fields and link/placement rules.
- Authoritative template location: `.obsidian/templates/` (versioned).
- Scripts location: `.obsidian/scripts/powershell/` with dry‑run support.
- Prompts location: `.obsidian/prompts/` (versioned). Original `.github/prompts`
	are treated as reference only and may be ignored by VCS.

## Development Workflow & Quality Gates

Commands (examples):
- `obsidian.create.idea` — generate an Idea note from description + template.
- `obsidian.create.project` — generate a Project note from description + template.
- `obsidian.elaborate` — add detail to an existing note respecting its template.
- `obsidian.clarify` — resolve ambiguities and fill required fields.
- `obsidian.challenge` — produce constructive critique and risks.

Quality gates:
- Constitution Check MUST pass before writing: structure, placement, naming,
	frontmatter completeness, and link validity (as applicable).
- Dry‑run diff MUST be reviewed by a human unless explicitly overridden.
- Versioning: templates, prompts, and scripts use SemVer; breaking changes
	require migration notes or helper scripts.
- Observability: logs/traces saved under `.agent/logs/` inside the repo or
	workspace, excluding sensitive content.

## Governance

- This constitution supersedes other practices for agent behaviors and vault
	content. Conflicts MUST be resolved in favor of this document.
- Amendments: propose via PR updating this file with a Sync Impact Report,
	version bump, and migration notes where applicable.
- Reviews MUST verify compliance with principles and quality gates.
- Constitution versioning uses SemVer:
	- MAJOR: breaking changes to principles or governance.
	- MINOR: new principle/section or materially expanded guidance.
	- PATCH: clarifications and non‑semantic edits.
- Compliance reviews SHOULD occur at least once per quarter or before major
	releases of templates/prompts.

**Version**: 0.4.0 | **Ratified**: TODO(RATIFICATION_DATE) | **Last Amended**: 2025-10-28
<!-- Example: Version: 2.1.1 | Ratified: 2025-06-13 | Last Amended: 2025-07-16 -->
