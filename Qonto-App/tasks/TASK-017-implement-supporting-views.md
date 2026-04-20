# TASK-017: Implement Supporting Views

## Goal
Create the reusable UI components for error, empty, and loading states.

## Context
Phase 4: Presentation. These components are used by the transaction list view to render non-happy-path states.

## Requirements
Create the following files in `UI/Components/`:

### 1. `ErrorView.swift`
- Full-screen centered layout
- SF Symbol: `exclamationmark.triangle` (large)
- Title: "Something went wrong"
- Message: Configurable string (passed in)
- Retry button: `Button("Try Again", action: retryAction)`
- Inputs: `message: String`, `retryAction: () -> Void`

### 2. `EmptyStateView.swift`
- Full-screen centered layout
- SF Symbol: `tray` (large)
- Title: "No transactions yet"
- Subtitle: "Your transactions will appear here"
- No action button needed

### 3. `LoadingView.swift`
- Full-screen centered `ProgressView`
- Optional label: "Loading transactions..."

### 4. `OfflineBannerView.swift`
- Horizontal strip (HStack)
- SF Symbol: `wifi.slash`
- Text: "You're viewing cached data. Pull to refresh when back online."
- Subtle background (e.g., `.yellow.opacity(0.15)`)
- Non-dismissible, compact

## Acceptance Criteria
- All 4 files exist in `UI/Components/`
- Each view is a separate `View` struct
- Views use SF Symbols, Dynamic Type, and `foregroundStyle()`
- No hard-coded font sizes
- ErrorView has a configurable message and retry action
- Views compile successfully

## Constraints
- Do NOT add navigation logic
- Do NOT import Domain types (these are pure UI components)
- Keep views simple and reusable

## Dependencies
- TASK-001 (folder structure)
