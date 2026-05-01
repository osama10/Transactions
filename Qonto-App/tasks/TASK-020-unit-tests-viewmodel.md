# TASK-020: Write Unit Tests for ViewModel

## Goal
Write unit tests for `TransactionListViewModel` covering state transitions, pagination, offline fallback, and edge cases.

## Context
Phase 5: Testing. The ViewModel is the most logic-heavy presentation component. Tests use a mock use case to verify behavior without network or database.

## Requirements
Create `Qonto-AppTests/TransactionListViewModelTests.swift`:

### Test doubles needed:
- `MockFetchTransactionsUseCase` implementing `FetchTransactionsUseCaseProtocol`
  - Configurable to return success or throw errors
  - Tracks call count and parameters

### Test cases:

**State transitions:**
- Initial state is `.loading`
- After successful load with data -> `.loaded`
- After successful load with 0 results -> `.empty`
- After failed load with no cache -> `.error(message)`
- After failed load with cache -> `.offline`

**Pagination:**
- `loadMoreTransactions` increments page and appends results
- Pagination guard: does not fetch when `isLoadingMore` is true
- Pagination guard: does not fetch when `hasMorePages` is false
- End detection: `results.count < pageSize` sets `hasMorePages = false`
- End detection: all-duplicate page sets `hasMorePages = false`
- Deduplication: duplicate IDs are not appended to the list

**Refresh:**
- `refresh()` resets page to 1, clears transactions, reloads
- `refresh()` calls `clearCache()` on the use case

**Offline:**
- When fetch fails and cache exists, transactions are loaded from cache
- ViewState is `.offline`

**`onTransactionAppear`:**
- Triggers `loadMoreTransactions` when transaction is near the end of the list
- Does NOT trigger when transaction is not near the end

## Acceptance Criteria
- Test file exists in `Qonto-AppTests/`
- Uses Swift Testing framework (`import Testing`)
- All tests pass
- Mock use case is properly configured for each test
- Tests verify both state changes and method calls
- Covers happy path, pagination edge cases, and offline scenarios

## Constraints
- Do NOT test UI rendering
- Do NOT use real network or database
- Do NOT use XCTest — use Swift Testing
- Tests must run without a host app (pure logic tests)

## Dependencies
- TASK-014 (ViewModel)
- TASK-012 (use case protocol — for mock)
