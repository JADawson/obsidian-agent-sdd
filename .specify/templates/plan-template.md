# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

> For Obsidian Agent projects: interpret this plan in the context of vault
> operations, prompts, and scripts. "Technical Context" should cover the
> target Obsidian vault, note types/templates, agent prompts, and PowerShell
> scripts rather than application code and frameworks.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Shell/Runtime**: [e.g., PowerShell 5.1/7.x; VS Code + Copilot]  
**Vault Path**: [absolute path to target Obsidian vault]  
**Note Types & Templates**: [e.g., Idea v1, Project v1]  
**Agent Prompts**: [e.g., obsidian.create.idea, obsidian.elaborate]  
**Scripts**: [PowerShell entrypoints and parameters]  
**Testing**: [dry‑run strategy, staging vault path, sample inputs]  
**Target Platform**: [Windows/macOS; local filesystem]  
**Project Type**: [Obsidian Agent / Vault automation]  
**Constraints**: [e.g., idempotent writes, least‑privilege IO, offline‑first]  
**Scale/Scope**: [e.g., expected note volume, folder counts]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

[Gates determined based on constitution file]

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

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
