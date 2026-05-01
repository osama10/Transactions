# TASK-021: Write Unit Tests for Repository

## Goal
Write unit tests for `TransactionRepository` to verify network-first strategy, offline fallback, and cache management.

## Context
Phase 5: Testing. The repository coordinates remote and local data sources. Tests use mock data sources to verify orchestration logic.

## Requirements
Create `Qonto-AppTests/TransactionRepositoryTests.swift`:

### Test doubles needed:
- `MockTransactionRemoteDataSource` implementing `TransactionRemoteDataSourceProtocol`
  - Configurable: return success response or throw error
- `MockTransactionLocalDataSource` implementing `TransactionLocalDataSourceProtocol`
  - In-memory storage for entities
  - Tracks method calls (save, deleteAll, fetchAll, hasData)

### Test cases:

**Network-first (online):**
- Successful fetch returns mapped domain models
- On page 1 success: `deleteAll` is called before saving
- On page > 1 success: `deleteAll` is NOT called (upsert only)
- Fetched data is saved to local data source

**Offline fallback:**
- When remote fails and local has data: returns cached domain models
- When remote fails and local is empty: throws the original error

**Cache operations:**
- `getCachedTransactions()` returns mapped entities from local
- `hasCache()` forwards to local `hasData()`
- `clearCache()` forwards to local `deleteAll()`

**Mapping verification:**
- DTOs are mapped via `TransactionDTOMapper` (correct domain models returned)
- Entities are mapped via `TransactionEntityMapper` (correct domain models from cache)

## Acceptance Criteria
- Test file exists in `Qonto-AppTests/`
- Uses Swift Testing framework (`import Testing`)
- All tests pass
- Mock data sources track calls for verification
- Network-first logic verified: remote first, local fallback
- Page 1 vs pagination behavior correctly tested
- No real network calls or database access

## Constraints
- Do NOT test mappers here (that's TASK-019)
- Do NOT test ViewModel logic
- Do NOT use XCTest — use Swift Testing
- Do NOT make real HTTP requests

## Dependencies
- TASK-013 (repository implementation)
- TASK-009 (remote data source protocol — for mock)
- TASK-010 (local data source protocol — for mock)
