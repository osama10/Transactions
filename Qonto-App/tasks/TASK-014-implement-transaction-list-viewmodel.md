# TASK-014: Implement Transaction List ViewModel

## Goal
Create the ViewModel that manages UI state, pagination logic, and orchestrates the use case for the transaction list screen.

## Context
Phase 4: Presentation. The ViewModel is `@Observable` and `@MainActor`. It owns pagination state and drives the view through a `ViewState` enum.

## Requirements
Create `UI/TransactionList/TransactionListViewModel.swift`:

### `TransactionListViewModel` (@Observable, @MainActor)
- Depends on `FetchTransactionsUseCaseProtocol` (injected via init)
- Use case returns `FetchResult` (`.fresh` or `.cached`), which the ViewModel uses to determine UI state

### State:
- `viewState: ViewState` — drives the UI
- `transactions: [Transaction]` — the accumulated list
- `currentPage: Int` — starts at 1
- `isLoadingMore: Bool` — prevents redundant pagination fetches
- `hasMorePages: Bool` — set false when end is detected

### ViewState enum:
```
enum ViewState {
    case loading
    case loaded
    case empty
    case error(String)
    case offline
}
```

### Constants:
- `pageSize = 30`

### Methods:

**`loadInitialTransactions()`**
- Set state to `.loading`
- Call use case with page 1
- On `.fresh`: set transactions, set state to `.loaded` (or `.empty` if 0 results)
- On `.cached`: set transactions, set state to `.offline`, set `hasMorePages = false`
- On throw: set state to `.error(message)`
- Detect end: if results.count < pageSize, set hasMorePages = false

**`loadMoreTransactions()`**
- Guard: return if `isLoadingMore` or `!hasMorePages`
- Set `isLoadingMore = true`
- Call use case with next page (always returns `.fresh` for page > 1, or throws)
- On success: deduplicate by `id`, append new transactions, increment page
- End detection: if results.count < pageSize OR all IDs already exist, set hasMorePages = false
- On failure: handle gracefully (keep existing data, show pagination error)
- Set `isLoadingMore = false`

**`refresh()`**
- Reset pagination state (page = 1, hasMorePages = true)
- Clear transactions list
- Call `loadInitialTransactions()`
- Note: no separate cache clear needed — repository handles it internally on successful page 1

**`onTransactionAppear(transaction:)`**
- Check if transaction is within last 5 items of the list
- If yes: trigger `loadMoreTransactions()`

## Scenarios the ViewModel Must Handle

| # | Scenario | Use Case Returns | ViewModel State |
|---|----------|-----------------|-----------------|
| 1 | Fresh launch, online | `.fresh(transactions)` | `.loaded`, pagination enabled |
| 2 | Fresh launch, offline, no cache | throws error | `.error(message)` with retry |
| 3 | Fresh launch, offline, has cache | `.cached(transactions)` | `.offline`, pagination disabled |
| 4 | Online, loses network mid-scroll | throws error (page > 1) | Keep existing list, show pagination error |
| 5 | Pull-to-refresh, offline | `.cached(transactions)` | `.offline`, cached data preserved |
| 6 | Pull-to-refresh, online | `.fresh(transactions)` | `.loaded`, fresh data, pagination reset |

## Acceptance Criteria
- File exists in `UI/TransactionList/`
- `@Observable` class, `@MainActor`
- ViewState enum covers all 5 states
- Uses `FetchResult.isCached` to distinguish fresh vs cached and set correct state
- On `.cached`: sets `.offline` state and disables pagination (`hasMorePages = false`)
- Pagination guards prevent redundant fetches
- Dual end-detection (< pageSize OR all duplicates)
- Deduplication by `transaction.id` before appending
- Pull-to-refresh resets pagination and reloads (no separate cache clear)
- Only depends on use case protocol (not repository or data sources)
- File compiles successfully

## Constraints
- Do NOT import SwiftData
- Do NOT reference DTOs or entities
- Do NOT put business rules here — only orchestration and UI state

## Dependencies
- TASK-002 (domain models)
- TASK-012 (use case)
- TASK-013 (FetchResult enum from Domain layer)
