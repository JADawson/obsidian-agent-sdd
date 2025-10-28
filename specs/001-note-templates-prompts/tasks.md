# Tasks: Note Templates & Prompts

**Input**: Design documents from `/specs/001-note-templates-prompts/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Not requested explicitly; skipping test tasks for now. Independent test criteria are listed per user story.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Obsidian Agent**: `.obsidian/prompts/`, `.obsidian/scripts/powershell/`, `.obsidian/templates/`, `Vault/` (target)
- Numbered Vault structure: `0) Ideas/`, `1) Goals/`, `2) Projects/`, `3) Areas/`, `4) Reference/`, `5) Archive/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create `.obsidian/templates/` directory
- [x] T002 Create `.obsidian/prompts/` directory (authoritative prompts for this project)
- [x] T003 Create `.obsidian/scripts/powershell/` directory
- [x] T004 [P] Create `.agent/logs/` directory (traces; ensure ignored by VCS)
- [x] T005 Create `.obsidian/config.json` with absolute vault path and folder mapping
- [x] T006 [P] Add README in `.obsidian/` documenting templates, prompts, scripts ownership

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T007 Implement helper module `.obsidian/scripts/powershell/helpers.ps1` (importable)
- [x] T008 [P] Add `Get-Slug`, `Get-ShortHash`, `New-NoteId` to helpers (slug+hash id)
- [x] T009 [P] Add `Sanitize-Filename`, `Resolve-VaultPath`, and folder mapping functions to helpers
- [x] T010 Implement `Write-Trace` (write JSON trace + diff to `.agent/logs/`)
- [x] T011 Implement `New-DryRunDiff` with human-approval gating (no write on dry-run)
- [x] T012 Define placement rules/constants in `.obsidian/scripts/powershell/helpers.ps1` per constitution (Idea→`0) Ideas/`, Project→`2) Projects/`, etc.)
- [x] T013 Create templates: `.obsidian/templates/idea.v1.md`
- [x] T014 [P] Create templates: `.obsidian/templates/goal.v1.md`
- [x] T015 [P] Create templates: `.obsidian/templates/project.v1.md`
- [x] T016 [P] Create templates: `.obsidian/templates/area.v1.md`
- [x] T017 [P] Create templates: `.obsidian/templates/activity-plan.v1.md`
- [x] T018 Create prompts: `.obsidian/prompts/obsidian.create.md` (covers Idea/Goal/Project/Area)
- [x] T019 [P] Create prompts: `.obsidian/prompts/obsidian.plan.md`
- [x] T020 [P] Create prompts: `.obsidian/prompts/obsidian.clarify.md`
- [x] T021 [P] Create prompts: `.obsidian/prompts/obsidian.elaborate.md`
- [x] T022 [P] Create prompts: `.obsidian/prompts/obsidian.challenge.md`
- [x] T023 Create script entrypoint `.obsidian/scripts/powershell/obsidian.create.ps1` (scaffold: parameters, dry-run switch, import helpers)
- [x] T024 Update `specs/001-note-templates-prompts/quickstart.md` with `.obsidian/config.json` usage and numbered vault rules

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Create an Idea note (Priority: P1) 🎯 MVP

**Goal**: Capture a new Idea using a single command; place under `0) Ideas/` with required frontmatter and curated tags; suggest related links.

**Independent Test**: Run `obsidian.create` with type `Idea` and a short description; verify one Markdown file in `Vault/0) Ideas/` with correct structure and frontmatter.

### Implementation for User Story 1

- [x] T025 [P] [US1] Implement Idea generation logic in `.obsidian/scripts/powershell/obsidian.create.ps1` (type=idea)
- [x] T026 [P] [US1] Write Idea frontmatter builder using template `.obsidian/templates/idea.v1.md`
- [x] T027 [US1] Enforce curated tags and general frontmatter in create flow (id, type, status, created, updated, tags)
- [x] T028 [US1] Ensure placement to `Vault/0) Ideas/` and filename sanitation
- [x] T029 [US1] Integrate dry-run diff + approval; on approve, write file and trace
- [x] T030 [US1] Update `.obsidian/prompts/obsidian.create.md` with Idea usage examples

**Checkpoint**: User Story 1 functional and independently testable

---

## Phase 4: User Story 2 - Plan from Idea to Project (Priority: P1)

**Goal**: Transform an Idea into a Project note under `2) Projects/` with required fields and links back to the Idea.

**Independent Test**: Run `obsidian.plan` targeting an Idea; verify new Project file under `Vault/2) Projects/` with links to source Idea.

### Implementation for User Story 2

- [x] T031 [P] [US2] Create script entrypoint `.obsidian/scripts/powershell/obsidian.plan.ps1` (scaffold: parameters, dry-run, import helpers)
- [x] T032 [P] [US2] Implement Idea→Project transformation (map fields; link back to Idea)
- [x] T033 [US2] Ensure placement to `Vault/2) Projects/` with `.obsidian/templates/project.v1.md`
- [x] T034 [US2] Add idempotent update behavior if Project already exists (no duplicate)
- [x] T035 [US2] Update `.obsidian/prompts/obsidian.plan.md` with usage examples

**Checkpoint**: User Stories 1 and 2 functional and independently testable

---

## Phase 5: User Story 3 - Clarify a Project (Priority: P2)

**Goal**: Ask targeted questions and propose clarifying edits for a selected Project; output dry-run diff for approval.

**Independent Test**: Run `obsidian.clarify` with a selected Project; verify proposed diff and questions without overwriting.

### Implementation for User Story 3

- [x] T036 [P] [US3] Create script entrypoint `.obsidian/scripts/powershell/obsidian.clarify.ps1` (scaffold: parameters, dry-run, import helpers)
- [x] T037 [P] [US3] Implement analyzer to read selected Project + linked notes (Idea/Goal)
- [x] T038 [US3] Generate up to N questions and a proposed diff; write to trace
- [x] T039 [US3] Update `.obsidian/prompts/obsidian.clarify.md` with usage examples

**Checkpoint**: All user stories independently functional

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T040 [P] Add README in `.obsidian/templates/` describing template versions and migration
- [ ] T041 Code cleanup and refactoring in `.obsidian/scripts/powershell/`
- [ ] T042 [P] Update `specs/001-note-templates-prompts/quickstart.md` with end-to-end examples
- [ ] T043 Security/safety hardening: validate path traversal and confirm vault boundary
- [ ] T044 [P] Add `.agent/logs/` rotation policy doc in repository README or `.agent/README.md`

Additional cleanup/polish tasks:

- [ ] T045 [P] Add `.obsidian/templates/README.md` documenting placeholders, required frontmatter (status enum, links.area), and conventions
- [ ] T046 Create `.agent/README.md` and document logs format, retention, and privacy considerations (fulfill T044 here)
- [ ] T047 Refactor helper verbs to approved names: `Sanitize-Filename` → `ConvertTo-FilenameSafe`, `Get-Slug` → `ConvertTo-Slug`; update module exports and script imports
- [ ] T048 Update prompt docs to reflect approved-verb refactor where referenced and ensure numbered Vault and `-Approve` examples across: `.obsidian/prompts/obsidian.create.md`, `.obsidian/prompts/obsidian.plan.md`, `.obsidian/prompts/obsidian.clarify.md`
- [ ] T049 Improve `obsidian.plan.ps1` idempotent updates: preserve existing body content on re-run; update only frontmatter fields when target Project already exists
- [ ] T050 Add `obsidian.validate.ps1` to scan Vault for spec violations (tags set, status enum, presence of `links.area`, vault boundary); dry-run by default with report to `.agent/logs/`
- [ ] T051 Verify `.gitignore` includes `.agent/`, OS/editor artifacts; append missing essentials if any
- [ ] T052 [P] Add `.vscode/tasks.json` with tasks to run create/plan/clarify (dry-run and approve) for quick access
- [ ] T053 Normalize CRLF handling in diffs and content writes; document newline policy in `.obsidian/README.md`

Elaborate & Challenge scripts (Option B):

- [x] T054 [P] Add script entrypoint `.obsidian/scripts/powershell/obsidian.elaborate.ps1` (scaffold: -SelectedPath, -DryRun default, -Approve, import helpers)
- [x] T055 [P] Implement v1 elaborate analyzer for Idea/Project: detect empty required fields/sections per template/spec; propose diff; update `updated:`; write trace to `.agent/logs/`
- [x] T056 Update `.obsidian/prompts/obsidian.elaborate.md` with usage examples and guardrails
- [x] T057 [P] Add script entrypoint `.obsidian/scripts/powershell/obsidian.challenge.ps1` (scaffold: -SelectedPath, -DryRun default, -Approve, import helpers)
- [x] T058 [P] Implement v1 challenge flow: add/update `## Risks`, `## Assumptions`, `## Improvements` sections; propose diff; update `updated:`; write trace
- [x] T059 Update `.obsidian/prompts/obsidian.challenge.md` with usage examples and guardrails

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): No dependencies
- Foundational (Phase 2): Depends on Setup completion — BLOCKS all user stories
- User Stories (Phase 3+): Depend on Foundational completion; can proceed in parallel afterward
- Polish (Final): Depends on desired stories being complete

### User Story Dependencies

- User Story 1 (P1): Starts after Foundational — No dependency on other stories
- User Story 2 (P1): Starts after Foundational — Integrates with US1 but remains independently testable
- User Story 3 (P2): Starts after Foundational — Reads Project and linked notes; independently testable

### Parallel Opportunities

- [P] tasks in Setup and Foundational can run concurrently
- Within US1/US2/US3, [P] tasks (different files) can run in parallel
- Different user stories can proceed in parallel after Foundational completion

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Setup
2. Complete Foundational (critical)
3. Implement US1 (Idea creation)
4. Validate independently via Quickstart steps

### Incremental Delivery

1. Setup + Foundational → baseline ready
2. US1 → validate → demo (MVP)
3. US2 → validate → demo
4. US3 → validate → demo

### Parallel Team Strategy

1. Team completes Setup + Foundational together
2. After Foundational:
   - Dev A: US1 (Idea)
   - Dev B: US2 (Plan)
   - Dev C: US3 (Clarify)
