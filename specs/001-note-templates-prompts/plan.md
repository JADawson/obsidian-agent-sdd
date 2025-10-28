# Implementation Plan: Note Templates & Prompts

**Branch**: `001-note-templates-prompts` | **Date**: 2025-10-28 | **Spec**: ../spec.md
**Input**: Feature specification from `/specs/001-note-templates-prompts/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

> For Obsidian Agent projects: interpret this plan in the context of vault
> operations, prompts, and scripts. "Technical Context" should cover the
> target Obsidian vault, note types/templates, agent prompts, and PowerShell
> scripts rather than application code and frameworks.

## Summary

Define initial Obsidian note types (Idea, Goal, Project, Area, Activity Plan)
and agent prompts (create, elaborate, clarify, plan, challenge). Establish
general + type-specific frontmatter, curated tags, and a hybrid `slug+hash`
identifier. Implement scripts with dry-run + idempotency and place all project
assets under `.obsidian/` per constitution.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Shell/Runtime**: PowerShell 5.1+; VS Code + Copilot  
**Vault Path**: ./Vault (Virtual Vault for development/testing)  
**Note Types & Templates**: Idea v1, Goal v1, Project v1, Area v1, Activity Plan v1 (per‑project only)  
**Agent Prompts**: obsidian.create, obsidian.elaborate, obsidian.clarify, obsidian.plan, obsidian.challenge  
**Scripts**: `.obsidian/scripts/powershell/obsidian.create.ps1` (create by type/infer), plus shared helpers for id generation (slug+hash), dry‑run, tracing  
**Testing**: Default dry‑run; use Virtual Vault for local tests; optional separate staging vault path (future)  
**Target Platform**: Windows; local filesystem  
**Project Type**: Obsidian Agent / Vault automation  
**Constraints**: Idempotent writes; least‑privilege IO; offline‑first; curated tags `{#idea, #goal, #project, #area, #plan}`; stable `id`  
**Scale/Scope**: Personal vault scale (note volume TBD)  

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Gates (must all pass):
- Markdown‑First, Vault‑Native: All outputs are Markdown in the configured vault ✔
- Template‑Driven, Prompt‑Oriented: Versioned templates + prompts per type ✔
- Deterministic & Idempotent Agents: Dry‑run by default; safe merges; no duplicates ✔
- Traceability & Human Review: Trace to `.agent/logs/`; human approval by default ✔
- Safety & Least Privilege: Operate only within vault; no destructive ops without opt‑in ✔
- Separation of Spec‑Kit Assets: Authoritative assets under `.obsidian/` ✔

Status: PASS (using Virtual Vault path ./Vault)

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Artefacts (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# Obsidian Agent (DEFAULT)
.obsidian/prompts/
.obsidian/scripts/powershell/
.obsidian/templates/   # markdown templates for note types (authoritative)
.agent/logs/           # traces & dry‑run outputs (not committed)
```

**Structure Decision**: Use `.obsidian/` as the authoritative location for
prompts, templates, and scripts. Keep `.specify/` and original `.github/` as
reference only (ignored by VCS). Logs under `.agent/logs/`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

## Phase 0: Outline & Research

Unknowns extracted from Technical Context:
- Vault Path (absolute) — confirm target vault folder
- Staging/Test Vault Path — confirm if separate path is desired

Tasks:
- Research vault path setup and staging strategy for safe dry-runs
- Confirm id generation implementation details (slug + hash length; 6 chars)

Output: see `research.md` (decisions confirmed; unknowns listed)

## Phase 1: Design & Contracts

Artifacts produced:
- `data-model.md` — entities, fields, relationships, validation rules
- `contracts/` — per-operation contracts for create, elaborate, clarify, plan, challenge
- `quickstart.md` — usage and safety notes

Agent context: update tracked separately via `.specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot`.

## Constitution Check (Post-Design)

Status: PASS (pending Vault Path confirmation). All artifacts align with principles and gates.
