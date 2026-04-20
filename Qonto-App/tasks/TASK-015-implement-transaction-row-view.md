# TASK-015: Implement Transaction Row View

## Goal
Create the SwiftUI view for a single transaction row in the list.

## Context
Phase 4: Presentation. The row view displays transaction details following the approved UI design from the plan.

## Requirements
Create `UI/TransactionList/TransactionRowView.swift`:

### Layout:
```
[Icon]  Counterparty Name          +EUR 1,234.56
        Card - Office supplies      Pending
        15 Jun 2025, 10:30
```

### Line 1: Counterparty + Amount
- Left: Operation method icon (SF Symbol) + counterparty name
- Right: Signed, colored amount
  - CREDIT: green, "+" prefix
  - DEBIT: primary text color, "-" prefix
  - Format amount using `.number.precision(.fractionLength(2))` with currency

### Line 2: Method + Description, Status Badge
- Left: Operation method label + description (e.g., "Card - Office supplies")
- Right: Status badge (colored capsule)
  - COMPLETED: green
  - PENDING: orange
  - DECLINED: red

### Line 3: Date
- Show `settledAt` if available, otherwise `emittedAt`
- Format: `.formatted(date: .abbreviated, time: .shortened)`

### Operation Method Icons (SF Symbols):
- CARD: `creditcard`
- TRANSFER: `arrow.left.arrow.right`
- DIRECT_DEBIT: `building.columns`

### Optional: Initiator Name
- If `initiatorName` is non-nil, show "by Alice Martin" as tertiary text

## Acceptance Criteria
- File exists in `UI/TransactionList/`
- Row displays all required fields: counterparty, amount, date, status
- Amount is color-coded by side (credit/debit)
- Status badge uses colored capsule
- Operation method icon displayed via SF Symbol
- Date formatted using modern FormatStyle API (not DateFormatter)
- Amount formatted using modern FormatStyle API (not NumberFormatter)
- Uses `foregroundStyle()` not `foregroundColor()`
- No hard-coded font sizes — uses Dynamic Type
- File compiles successfully

## Constraints
- Do NOT use `onTapGesture` (rows are not tappable per scope)
- Do NOT use UIKit colors
- Do NOT use deprecated SwiftUI modifiers
- Do NOT break the view into computed properties — use sub-View structs if needed

## Dependencies
- TASK-002 (domain models — `Transaction`)
