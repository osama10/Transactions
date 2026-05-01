# TASK-007: Implement DTO Mapper

## Goal
Create the mapper that converts API DTOs into domain models.

## Context
Phase 2: Data Layer. This mapper lives in `Data/Mappers/` and is called by the repository. The Domain layer never knows about DTOs — this mapper is the boundary.

## Requirements
Create `Data/Mappers/TransactionDTOMapper.swift`:

### `TransactionDTOMapper`
- Struct with static methods
- `static func mapToDomain(dto: TransactionDTO) -> Transaction?`
  - Returns nil if required parsing fails (defensive)
- `static func mapToDomain(dtos: [TransactionDTO]) -> [Transaction]`
  - Maps array, filtering out any that fail to parse

### Mapping logic:
- `amount`: Parse `dto.amount.value` (String) to `Decimal`
- `emittedAt`: Parse ISO 8601 string to `Date`
- `settledAt`: Parse ISO 8601 string to `Date?` (nil if null)
- `side`: Map string "CREDIT"/"DEBIT" to `TransactionSide` enum
- `status`: Map string to `TransactionStatus` enum
- `operationMethod`: Map string to `OperationMethod` enum
- `operationType`: Map string to `OperationType` enum
- `activityTag`: Map string to `ActivityTag` enum
- `initiatorName`: Flatten `dto.initiator?.fullName`
- `bankAccountName`: Flatten `dto.bankAccount.name`
- All other fields: direct assignment

### Date parsing:
- Use ISO 8601 date strategy (the API returns `"2025-06-15T10:30:00.000Z"` format)

## Acceptance Criteria
- File exists in `Data/Mappers/`
- Maps all DTO fields to domain model fields correctly
- Handles optional fields (settledAt, note, initiator) gracefully
- Returns nil for unparseable DTOs (defensive, no force unwraps)
- Does NOT live on the domain model — it's a standalone struct in the Data layer
- File compiles successfully

## Constraints
- Do NOT put mapping logic on `Transaction` (domain must not know about DTOs)
- Do NOT use force unwraps or force try
- Do NOT add entity mapping here (that's TASK-008)

## Dependencies
- TASK-002 (domain models)
- TASK-005 (DTOs)
