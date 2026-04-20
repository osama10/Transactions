# TASK-006: Define SwiftData Entity

## Goal
Create the SwiftData `@Model` class that represents a persisted transaction in the local database.

## Context
Phase 2: Data Layer. The entity is the database representation, used by the local data source for CRUD operations. Fields are stored as primitive types (strings for enums, flattened nested objects).

## Requirements
Create `Data/Local/TransactionEntity.swift`:

### `TransactionEntity` (@Model)
| Field | Type | Notes |
|-------|------|-------|
| id | String | primary key |
| counterpartyName | String | |
| amount | Decimal | |
| currency | String | |
| emittedAt | Date | |
| settledAt | Date? | |
| side | String | raw value of TransactionSide |
| status | String | raw value of TransactionStatus |
| operationMethod | String | raw value of OperationMethod |
| operationType | String | raw value of OperationType |
| descriptionText | String | avoids collision with `description` |
| activityTag | String | raw value of ActivityTag |
| note | String? | |
| initiatorName | String? | flattened from initiator.fullName |
| bankAccountName | String | flattened from bankAccount.name |
| page | Int | tracks which page this came from |

- All non-optional fields must have default values (SwiftData requirement)
- Use `id` as the unique identifier via `@Attribute(.unique)`

## Acceptance Criteria
- `TransactionEntity.swift` exists in `Data/Local/`
- Class is annotated with `@Model`
- All fields match the table above with correct types and optionality
- `id` is marked with `@Attribute(.unique)`
- All non-optional properties have default values
- Imports `SwiftData`
- File compiles successfully (once persistence controller references it)

## Constraints
- Do NOT add domain enums here — store as raw String values
- Do NOT add mapping methods on this class (that's TASK-008)
- Do NOT add CRUD operations (that's TASK-010)

## Dependencies
- TASK-001 (folder structure)
- Enables TASK-004 to fully compile (PersistenceController references this model)
