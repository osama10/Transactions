# TASK-022: Manual Testing and Bug Fixes

## Goal
Perform end-to-end manual testing of the app, fix any bugs discovered, and verify all acceptance criteria from the product spec.

## Context
Phase 6: Polish. All features are implemented. This task validates everything works together in a real environment.

## Requirements

### Test scenarios to verify:

**Happy path:**
- App launches and loads first page of transactions
- Transactions display correctly (counterparty name, amount, date, status badge)
- Amounts are color-coded (green with "+" for credit, default with "-" for debit)
- Status badges show correct colors (green=Completed, orange=Pending, red=Declined)
- Operation icon matches method (creditcard=Card, arrows=Transfer, building=Direct Debit)
- Method description and transaction description shown on second line

**Pagination:**
- Scrolling near bottom triggers loading more transactions
- Loading footer (ProgressView) appears during pagination
- New transactions append without duplicates
- Multiple pages load correctly in sequence
- No redundant fetches on fast scrolling

**Pull-to-refresh:**
- Pull down refreshes the list from page 1
- Old data is replaced with fresh data
- Pagination resets after refresh (can scroll to load more again)

**Offline banner (real-time):**
- Turn off wifi -> red "No Internet" banner appears at top instantly
- Turn on wifi -> banner disappears with animation
- Banner pushes list content down (doesn't overlap)

**Offline with cache:**
- Load data -> airplane mode -> cached data still visible on screen
- Kill and relaunch app in airplane mode -> cached data loads from SwiftData

**Offline without cache:**
- First launch in airplane mode (no cache) -> error screen with "Try Again" button
- Restore network -> tap "Try Again" -> loads successfully

**Error states:**
- Error view appears on first load failure (no cache)
- Retry button triggers fresh load from page 1
- Pagination failure is silent — existing data stays, user can scroll again
- Refresh failure with data is silent — existing data stays

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
