# TASK-001: Create Folder Structure

## Goal
Set up the Xcode project folder structure matching the approved architecture.

## Context
Phase 1: Foundation. This is the first task — it establishes the physical organization that all subsequent tasks build upon.

## Requirements
Create the following folder groups inside `Qonto-App/`:

```
Core/
  Networking/
  Persistence/
Domain/
  Models/
  UseCases/
  Repositories/
Data/
  DTOs/
  Local/
  Remote/
  Mappers/
  Repositories/
UI/
  TransactionList/
  Components/
App/
```

- Move existing `Qonto_AppApp.swift` into `App/`
- Remove the default `ContentView.swift` (will be replaced by task views later)
- Ensure all folders are registered as groups in the Xcode project

## Acceptance Criteria
- All folders exist as Xcode groups in the project navigator
- `Qonto_AppApp.swift` is in `App/`
- `ContentView.swift` is removed
- Project builds successfully (even if the app entry point references a missing view — a placeholder is acceptable)

## Constraints
- Do NOT create any Swift files other than moving existing ones
- Do NOT add placeholder files in empty folders
- Do NOT modify the architecture

## Dependencies
None — this is the first task.
