# TASK-004: Implement Persistence Controller

## Goal
Create the SwiftData container setup that provides the `ModelContainer` for the app.

## Context
Phase 1: Foundation. The persistence controller lives in Core and provides the SwiftData infrastructure used by the local data source (TASK-010).

## Requirements
Create `Core/Persistence/PersistenceController.swift`:

- Struct or enum `PersistenceController`
- Creates a `ModelContainer` configured for `TransactionEntity` (the model will be defined in TASK-006)
- Provides a static method or property to create the container
- Supports an in-memory configuration for testing/previews
- All operations will use `mainContext` (as per the plan's threading decision)

**Note:** Since `TransactionEntity` doesn't exist yet, this file may reference it forward. It will compile once TASK-006 is complete. Alternatively, the container setup can be generic enough to accept a schema later.

## Acceptance Criteria
- `PersistenceController.swift` exists in `Core/Persistence/`
- Provides a way to create a `ModelContainer`
- Supports both persistent (on-disk) and in-memory configurations
- Uses `@MainActor` where appropriate (mainContext is `@MainActor`)
- No business logic, no domain knowledge

## Constraints
- Do NOT create the `TransactionEntity` model here (that's TASK-006)
- Do NOT add CRUD operations (that's the local data source)
- Keep it minimal — just container setup

## Dependencies
- TASK-001 (folder structure)
- Will fully compile after TASK-006 (TransactionEntity)
