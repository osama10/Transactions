# TASK-013: Implement Transaction Repository

## Goal
Create the concrete repository that coordinates between remote and local data sources, implementing a network-first strategy with page-1-only offline fallback.

## Context
Phase 3: Data Layer (Repository). This is the most critical Data layer component — it implements the domain's repository protocol and owns the data flow logic.

## Key Design Decisions
- **`FetchResult` enum:** The repository returns `.fresh([Transaction])` or `.cached([Transaction])` so the ViewModel can distinguish remote data from offline fallback and show the appropriate UI (e.g. offline banner, disable pagination).
- **Page-1-only fallback:** Offline cache is only served on page 1 failure (app launch with no network). If page 2+ fails, the error is thrown — user already has data on screen, and the ViewModel shows a pagination retry.
- **No separate `clearCache()`:** Cache is cleared internally on successful page 1 fetch. This prevents the "pull-to-refresh offline" bug where clearing cache before fetching would destroy the safety net if the fetch fails.

## Requirements
Create `Data/Repositories/TransactionRepository.swift`:

### `TransactionRepository` (implements `TransactionRepositoryProtocol`)
- Depends on:
  - `TransactionRemoteDataSourceProtocol`
  - `TransactionLocalDataSourceProtocol`
- Uses mappers: `TransactionDTOMapper`, `TransactionEntityMapper`

### `fetchTransactions(page:results:)` → `FetchResult`:
Network-first strategy with three extracted helpers:

**`fetchRemote(page:results:)` → `[Transaction]`:**
- Fetch from remote data source using fixed seed `"qonto"`
- Map DTOs to domain models via `TransactionDTOMapper`

**`cacheLocally(transactions:page:)`:**
- If page == 1: clear all local cache first (`deleteAll`)
- Map domain models to entities via `TransactionEntityMapper`
- Save entities via local data source
- Cache failures are non-fatal (silently caught)

**`loadCachedTransactions()` → `[Transaction]?`:**
- Check `hasData()`, fetch all entities, map to domain models
- Returns nil if no cache exists

**Main flow:**
1. Try `fetchRemote` → `cacheLocally` → return `.fresh(transactions)`
2. On failure, if page == 1 and cache exists → return `.cached(transactions)`
3. Otherwise rethrow the error

## Scenarios Handled

| # | Scenario | Repository Behavior | Expected UI |
|---|----------|-------------------|-------------|
| 1 | Fresh launch, online | Remote success → cache → `.fresh` | Loading → Loaded list |
| 2 | Fresh launch, offline, no cache | Remote fails → no cache → throws | Loading → Error + retry |
| 3 | Fresh launch, offline, has cache | Remote fails → page 1 → cache hit → `.cached` | Loading → Offline banner + cached list |
| 4 | Online, loses network mid-scroll | Page N fails → not page 1 → throws | Existing list stays, pagination error footer |
| 5 | Pull-to-refresh, offline | Remote fails → page 1 → cache still intact → `.cached` | Cached data preserved + offline banner |
| 6 | Pull-to-refresh, online | Remote success → `deleteAll` old cache → save fresh → `.fresh` | List refreshes with fresh data |

## Acceptance Criteria
- File exists in `Data/Repositories/`
- Implements `TransactionRepositoryProtocol`
- Returns `FetchResult` (`.fresh` or `.cached`)
- Network-first: tries remote, falls back to local on page 1 failure only
- On page 1 success: clears old cache before saving new data
- On pagination success: upserts without clearing
- Cache is never cleared before a successful fetch (protects offline safety net)
- Uses mappers from `Data/Mappers/`
- Fixed seed `"qonto"` used for all API calls
- File compiles successfully

## Constraints
- Do NOT put pagination state here (that's the ViewModel)
- Do NOT expose DTOs or entities outside this class
- The repository returns `FetchResult` containing domain models

## Dependencies
- TASK-007 (DTO mapper)
- TASK-008 (entity mapper)
- TASK-009 (remote data source)
- TASK-010 (local data source)
- TASK-011 (repository protocol)
