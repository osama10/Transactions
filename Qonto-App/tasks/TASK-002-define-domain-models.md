# TASK-002: Define Domain Models

## Goal
Create the `Transaction` domain model and all associated enums in the Domain layer.

## Context
Phase 1: Foundation. Domain models are the core of the app — DTOs, entities, mappers, and ViewModels all depend on them. Must be created before any Data layer types.

## Requirements
Create `Domain/Models/Transaction.swift` containing:

**`Transaction` struct** (Sendable, Hashable, Identifiable):
| Field | Type |
|-------|------|
| id | String |
| counterpartyName | String |
| amount | Decimal |
| currency | String |
| emittedAt | Date |
| settledAt | Date? |
| side | TransactionSide |
| status | TransactionStatus |
| operationMethod | OperationMethod |
| operationType | OperationType |
| description | String |
| activityTag | ActivityTag |
| note | String? |
| initiatorName | String? |
| bankAccountName | String |

**Enums** (all `String`-backed, `Sendable`, `Hashable`):
- `TransactionSide`: `.credit`, `.debit`
- `TransactionStatus`: `.completed`, `.pending`, `.declined`
- `OperationMethod`: `.transfer`, `.card`, `.directDebit`
- `OperationType`: `.income`, `.transfer`, `.card`
- `ActivityTag`: `.otherIncome`, `.otherExpense`, `.otherService`, `.refund`, `.fees`

## Acceptance Criteria
- `Transaction.swift` exists in `Domain/Models/`
- `Transaction` is a struct conforming to `Sendable`, `Hashable`, `Identifiable`
- All 5 enums are defined with correct cases and raw values
- Enums conform to `String`, `Sendable`, `Hashable` — NOT `Codable`
- No imports of SwiftData, SwiftUI, or Foundation networking
- File compiles without errors

## Constraints
- Do NOT add `Codable` to domain types
- Do NOT import any framework other than `Foundation`
- Do NOT create mapper logic here
- Do NOT create any other files

## Dependencies
- TASK-001 (folder structure must exist)
