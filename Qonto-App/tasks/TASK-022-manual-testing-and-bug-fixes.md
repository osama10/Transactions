# TASK-022: Manual Testing and Bug Fixes

## Goal
Perform end-to-end manual testing of the app, fix any bugs discovered, and verify all acceptance criteria from the product spec.

## Context
Phase 6: Polish. All features are implemented. This task validates everything works together in a real environment.

## Requirements

### Test scenarios to verify:

**Happy path:**
- App launches and loads first page of transactions
- Transactions display correctly (counterparty, amount, date, status)
- Amounts are color-coded (green for credit, default for debit)
- Status badges show correct colors
- Transactions are grouped by date, sorted most recent first

**Pagination:**
- Scrolling near bottom triggers loading more transactions
- Loading footer (ProgressView) appears during pagination
- New transactions append without duplicates
- Multiple pages load correctly in sequence
- No redundant fetches on fast scrolling

**Pull-to-refresh:**
- Pull down refreshes the list from page 1
- Old data is replaced with fresh data
- Pagination resets after refresh

**Offline:**
- Kill network (airplane mode) after loading data -> cached data still visible
- Offline banner appears with correct message
- Kill network before first load with no cache -> error screen with retry
- Restore network and retry -> loads successfully

**Error states:**
- Error view appears on first load failure (no cache)
- Retry button works
- Pagination error shows inline, existing data stays visible

**Empty state:**
- If API returns 0 results -> "No transactions yet" screen

**Edge cases:**
- Rotate device -> layout adapts
- Dynamic Type changes -> text scales
- Very long counterparty names -> text truncates gracefully

## Acceptance Criteria
- All scenarios above pass
- No crashes
- No visual glitches
- Performance is smooth (no jank on scroll)
- All bugs found during testing are fixed

## Constraints
- Do NOT add new features
- Do NOT refactor architecture
- Only fix bugs and polish issues discovered during testing

## Dependencies
- TASK-018 (app must be fully wired and runnable)
