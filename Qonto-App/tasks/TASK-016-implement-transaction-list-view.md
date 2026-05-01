# TASK-016: Implement Transaction List View

## Goal
Create the main screen of the app — a scrollable list of transactions with pagination, pull-to-refresh, and all UI states.

## Context
Phase 4: Presentation. This view observes the ViewModel and renders the appropriate state. It's the single screen of the application.

## Requirements
Create `UI/TransactionList/TransactionListView.swift`:

### Structure:
- `NavigationStack` with title "Transactions"
- Content driven by `viewModel.viewState`

### State rendering:
- `.loading` -> Full-screen `ProgressView`
- `.loaded` -> Transaction list with section headers
- `.empty` -> `EmptyStateView`
- `.error(message)` -> `ErrorView` with retry action
- `.offline` -> Transaction list + offline banner

### Transaction List:
- `List` with `ForEach`
- Group transactions by day using `emittedAt` (section headers)
- Sort sections in descending order (most recent first)
- Each row: `TransactionRowView`
- `.onAppear` on each row: call `viewModel.onTransactionAppear(transaction:)` for pagination trigger

### Pagination footer:
- When `viewModel.isLoadingMore` is true, show `ProgressView` as last item

### Offline banner:
- When state is `.offline`, show a non-dismissible strip below nav bar
- `wifi.slash` SF Symbol + "You're viewing cached data. Pull to refresh when back online."
- Subtle background color to distinguish from content

### Pull-to-refresh:
- `.refreshable` modifier on the list
- Calls `viewModel.refresh()`

### On appear:
- `.task` modifier to call `viewModel.loadInitialTransactions()` on first appear

### Scroll indicators:
- Use `.scrollIndicators(.hidden)` if desired

## Acceptance Criteria
- File exists in `UI/TransactionList/`
- All 5 view states rendered correctly
- Transactions grouped by date with section headers
- Sections sorted descending (most recent first)
- Pagination triggers on scroll near bottom
- Loading footer visible during pagination
- Offline banner shown in offline state
- Pull-to-refresh works via `.refreshable`
- Uses `NavigationStack` (not `NavigationView`)
- File compiles successfully

## Constraints
- Do NOT use `NavigationView`
- Do NOT use `GeometryReader` for layout
- Do NOT use `AnyView`
- Do NOT put logic in the view — delegate to ViewModel
- Do NOT use `ScrollViewReader` — use modern scroll APIs if needed

## Dependencies
- TASK-014 (ViewModel)
- TASK-015 (TransactionRowView)
- TASK-017 (supporting views — ErrorView, EmptyStateView)
