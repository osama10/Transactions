# Master Task List

## Workflow Rules

1. Claude **must read this file** (`tasks/MASTER_TASK.md`) to determine the next task.
2. Claude may **only execute the next pending task** after explicit user approval.
3. **Only one task** should be implemented at a time.
4. A task can **only be marked done after user approval**.

### Git Branching

5. If a local git repo does not exist, **create one first** before any task work.
6. Before starting a task, **create a feature branch** named after the task file (e.g., `TASK-001-create-folder-structure`).
7. All task work must be done on the feature branch.

### Task Completion

8. After completing a task, Claude **must wait for user review**.
9. Once the user approves the task:
   - Merge the feature branch into `feature/qonto-test`only. 
   - Delete the feature branch
   - Mark the task as **done** in this file
   - Move to the next task

10. When starting a task, Claude must **update its status to IN_PROGRESS** in this file before implementation.
11. **Only one task** may have the status NEXT at any time.
12. Claude must **not modify task definitions, order, or dependencies** unless explicitly instructed.
13. If a task cannot be completed, mark it as **BLOCKED** and explain why.
14. The NEXT task becomes **IN_PROGRESS** when execution begins.

Rules:
- Do not work on any other task
- Do not anticipate future tasks
- Stay strictly within the scope of the selected task
- Respect out-of-scope items in the task file
- After implementation, do not mark the task as done yet

Return:
1. which task you executed
2. files created/changed
3. what was implemented
4. anything that needs my review before approval

---

## Task List

| Task ID  | Description                              | Status      | Dependencies                          | Task File |
|----------|------------------------------------------|-------------|---------------------------------------|-----------|
| TASK-001 | Create folder structure                  | DONE        | none                                  | [TASK-001](TASK-001-create-folder-structure.md) |
| TASK-002 | Define domain models                     | DONE        | TASK-001                              | [TASK-002](TASK-002-define-domain-models.md) |
| TASK-003 | Implement networking layer               | DONE        | TASK-001                              | [TASK-003](TASK-003-implement-networking-layer.md) |
| TASK-004 | Implement persistence controller         | DONE        | TASK-001                              | [TASK-004](TASK-004-implement-persistence-controller.md) |
| TASK-005 | Define API DTOs                          | DONE        | TASK-001                              | [TASK-005](TASK-005-define-api-dtos.md) |
| TASK-006 | Define SwiftData entity                  | DONE        | TASK-001                              | [TASK-006](TASK-006-define-swiftdata-entity.md) |
| TASK-007 | Implement DTO mapper                     | DONE        | TASK-002, TASK-005                    | [TASK-007](TASK-007-implement-dto-mapper.md) |
| TASK-008 | Implement entity mapper                  | DONE        | TASK-002, TASK-006                    | [TASK-008](TASK-008-implement-entity-mapper.md) |
| TASK-009 | Implement remote data source             | DONE        | TASK-003, TASK-005                    | [TASK-009](TASK-009-implement-remote-data-source.md) |
| TASK-010 | Implement local data source              | DONE        | TASK-004, TASK-006                    | [TASK-010](TASK-010-implement-local-data-source.md) |
| TASK-011 | Define repository protocol               | DONE        | TASK-002                              | [TASK-011](TASK-011-define-repository-protocol.md) |
| TASK-012 | Implement fetch transactions use case    | DONE        | TASK-002, TASK-011                    | [TASK-012](TASK-012-implement-fetch-transactions-use-case.md) |
| TASK-013 | Implement transaction repository         | DONE        | TASK-007, TASK-008, TASK-009, TASK-010, TASK-011 | [TASK-013](TASK-013-implement-transaction-repository.md) |
| TASK-014 | Implement transaction list ViewModel     | NEXT        | TASK-002, TASK-012                    | [TASK-014](TASK-014-implement-transaction-list-viewmodel.md) |
| TASK-015 | Implement transaction row view           | NOT_STARTED | TASK-002                              | [TASK-015](TASK-015-implement-transaction-row-view.md) |
| TASK-017 | Implement supporting views               | NOT_STARTED | TASK-001                              | [TASK-017](TASK-017-implement-supporting-views.md) |
| TASK-016 | Implement transaction list view          | NOT_STARTED | TASK-014, TASK-015, TASK-017          | [TASK-016](TASK-016-implement-transaction-list-view.md) |
| TASK-018 | Set up DI container and app wiring       | NOT_STARTED | TASK-001, TASK-002, TASK-003, TASK-004, TASK-005, TASK-006, TASK-007, TASK-008, TASK-009, TASK-010, TASK-011, TASK-012, TASK-013, TASK-014, TASK-015, TASK-016, TASK-017 | [TASK-018](TASK-018-setup-di-container-and-app-wiring.md) |
| TASK-019 | Write unit tests for mappers             | NOT_STARTED | TASK-007, TASK-008                    | [TASK-019](TASK-019-unit-tests-mappers.md) |
| TASK-020 | Write unit tests for ViewModel           | NOT_STARTED | TASK-014, TASK-012                    | [TASK-020](TASK-020-unit-tests-viewmodel.md) |
| TASK-021 | Write unit tests for repository          | NOT_STARTED | TASK-013, TASK-009, TASK-010          | [TASK-021](TASK-021-unit-tests-repository.md) |
| TASK-022 | Manual testing and bug fixes             | NOT_STARTED | TASK-018                              | [TASK-022](TASK-022-manual-testing-and-bug-fixes.md) |
| TASK-023 | Write technical debrief document         | NOT_STARTED | all previous tasks                    | [TASK-023](TASK-023-write-technical-debrief.md) |
| TASK-024 | Add OSLog logger for non-fatal events    | NOT_STARTED | TASK-013, TASK-007, TASK-008          | [TASK-024](TASK-024-add-os-logger.md) |

---

## Phases Overview

### Phase 1 - Foundation (TASK-001 to TASK-004)
Set up project folder structure, domain models, networking layer, and persistence controller.

### Phase 2 - Data Layer (TASK-005 to TASK-010)
DTOs, SwiftData entity, mappers, remote data source, and local data source.

### Phase 3 - Domain (TASK-011 to TASK-012)
Repository protocol and fetch transactions use case.

### Phase 4 - Data Repository (TASK-013)
Concrete repository coordinating remote + local with network-first strategy.

### Phase 5 - Presentation (TASK-014 to TASK-018)
ViewModel, row view, list view, supporting views, DI container, and app wiring.

### Phase 6 - Testing & Polish (TASK-019 to TASK-023)
Unit tests for mappers, ViewModel, and repository. Manual testing, bug fixes, and technical debrief.
