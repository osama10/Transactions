# TASK-010: Implement Local Data Source

## Goal
Create the local data source that provides CRUD operations on SwiftData for transaction entities.

## Context
Phase 2: Data Layer. The local data source operates on `mainContext` and provides persistence for offline access and caching.

## Requirements
Create `Data/Local/TransactionLocalDataSource.swift`:

### Protocol: `TransactionLocalDataSourceProtocol`
- `func fetchAll() async throws -> [TransactionEntity]`
- `func save(entities: [TransactionEntity], page: Int) async throws`
- `func deleteAll() async throws`
- `func deleteOldestPages(keeping maxPages: Int) async throws`
- `func hasData() async -> Bool`
- Protocol must be `Sendable`

### Implementation: `TransactionLocalDataSource`
- Annotated with `@MainActor` (all operations on mainContext)
- Depends on `ModelContainer` (injected via init)
- Uses `modelContainer.mainContext` for all operations

### Method details:

**`fetchAll()`**
- Fetch all `TransactionEntity` records
- Sort by `emittedAt` descending (most recent first)

**`save(entities:page:)`**
- Upsert logic: for each entity, check if one with the same `id` exists
  - If yes: update it
  - If no: insert it
- After insert, call `deleteOldestPages(keeping:)` to enforce the storage cap

**`deleteAll()`**
- Delete all `TransactionEntity` records (used on pull-to-refresh)

**`deleteOldestPages(keeping:)`**
- Find all distinct page numbers stored
- If count > maxPages, delete entities from the lowest page numbers
- `maxCachedPages = 5` (define as a constant)

**`hasData()`**
- Return true if at least one entity exists

## Acceptance Criteria
- Protocol + implementation exist in `Data/Local/`
- All operations use `mainContext` (no background `@ModelActor`)
- Upsert by `id` works correctly
- Storage cap enforced at 5 pages
- `deleteAll` clears everything
- `fetchAll` returns sorted results (most recent first)
- File compiles successfully

## Constraints
- Do NOT map entities to domain models here (that's the repository's job)
- Do NOT import Domain layer types
- Do NOT use `@ModelActor` — use `mainContext`

## Dependencies
- TASK-004 (persistence controller)
- TASK-006 (TransactionEntity)
