# TASK-013: Implement Transaction Repository

## Goal
Create the concrete repository that coordinates between remote and local data sources, implementing the network-first strategy with offline fallback.

## Context
Phase 3: Data Layer (Repository). This is the most critical Data layer component — it implements the domain's repository protocol and owns the data flow logic.

## Requirements
Create `Data/Repositories/TransactionRepository.swift`:

### `TransactionRepository` (implements `TransactionRepositoryProtocol`)
- Depends on:
  - `TransactionRemoteDataSourceProtocol`
  - `TransactionLocalDataSourceProtocol`
- Uses mappers: `TransactionDTOMapper`, `TransactionEntityMapper`

### `fetchTransactions(page:results:)`:
Network-first strategy:
1. Attempt remote fetch via remote data source (using fixed seed `"qonto"`)
2. **Success:**
   - If page == 1: clear all local cache first (`deleteAll`)
   - Map DTOs to domain models via `TransactionDTOMapper`
   - Map domain models to entities via `TransactionEntityMapper`
   - Save entities to local via local data source
   - Return domain models
3. **Failure:**
   - If local cache exists: fetch entities, map to domain models, return them
   - If no cache: rethrow the error

### `getCachedTransactions()`:
- Fetch all entities from local data source
- Map to domain models via `TransactionEntityMapper`
- Return them

### `hasCache()`:
- Forward to local data source's `hasData()`

### `clearCache()`:
- Forward to local data source's `deleteAll()`

## Acceptance Criteria
- File exists in `Data/Repositories/`
- Implements `TransactionRepositoryProtocol`
- Network-first: tries remote, falls back to local on failure
- On page 1 success: clears old cache before saving new data
- On pagination success: upserts without clearing
- Uses mappers from `Data/Mappers/` (not on domain types)
- Fixed seed `"qonto"` used for all API calls
- File compiles successfully

## Constraints
- Do NOT put pagination state here (that's the ViewModel)
- Do NOT expose DTOs or entities outside this class
- The repository returns only domain models

## Dependencies
- TASK-007 (DTO mapper)
- TASK-008 (entity mapper)
- TASK-009 (remote data source)
- TASK-010 (local data source)
- TASK-011 (repository protocol)
