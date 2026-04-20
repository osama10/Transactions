# TASK-014: Implement Transaction List ViewModel

## Goal
Create the ViewModel that manages UI state, pagination logic, and orchestrates the use case for the transaction list screen.

## Context
Phase 4: Presentation. The ViewModel is `@Observable` and `@MainActor`. It owns pagination state and drives the view through a `ViewState` enum.

## Requirements
Create `UI/TransactionList/TransactionListViewModel.swift`:

### `TransactionListViewModel` (@Observable, @MainActor)
- Depends on `FetchTransactionsUseCaseProtocol` (injected via init)

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
- On success: set transactions, set state to `.loaded` (or `.empty` if 0 results)
- On failure + cache exists: load cache, set state to `.offline`
- On failure + no cache: set state to `.error(message)`
- Detect end: if results.count < pageSize, set hasMorePages = false

**`loadMoreTransactions()`**
- Guard: return if `isLoadingMore` or `!hasMorePages`
- Set `isLoadingMore = true`
- Call use case with next page
- On success: deduplicate by `id`, append new transactions, increment page
- End detection: if results.count < pageSize OR all IDs already exist, set hasMorePages = false
- On failure: handle gracefully (keep existing data, show pagination error)
- Set `isLoadingMore = false`

**`refresh()`**
- Clear cache via use case
- Reset pagination state (page = 1, hasMorePages = true)
- Clear transactions list
- Call `loadInitialTransactions()`

**`onTransactionAppear(transaction:)`**
- Check if transaction is within last 5 items of the list
- If yes: trigger `loadMoreTransactions()`

## Acceptance Criteria
- File exists in `UI/TransactionList/`
- `@Observable` class, `@MainActor`
- ViewState enum covers all 5 states
- Pagination guards prevent redundant fetches
- Dual end-detection (< pageSize OR all duplicates)
- Deduplication by `transaction.id` before appending
- Pull-to-refresh resets everything and reloads
- Only depends on use case protocol (not repository or data sources)
- File compiles successfully

## Constraints
- Do NOT import SwiftData
- Do NOT reference DTOs or entities
- Do NOT put business rules here — only orchestration and UI state

## Dependencies
- TASK-002 (domain models)
- TASK-012 (use case)
