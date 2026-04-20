# TASK-008: Implement Entity Mapper

## Goal
Create the mapper that converts between domain models and SwiftData entities (bidirectional).

## Context
Phase 2: Data Layer. This mapper lives in `Data/Mappers/` and is used by the local data source and repository for persistence operations.

## Requirements
Create `Data/Mappers/TransactionEntityMapper.swift`:

### `TransactionEntityMapper`
- Struct with static methods

### Domain -> Entity:
- `static func mapToEntity(domain: Transaction, page: Int) -> TransactionEntity`
  - Direct field-to-field mapping
  - Enums stored as `.rawValue` strings
  - `page` parameter tracks which API page this transaction came from

### Entity -> Domain:
- `static func mapToDomain(entity: TransactionEntity) -> Transaction?`
  - Reconstruct enums from raw string values
  - Returns nil if any enum reconstruction fails
- `static func mapToDomain(entities: [TransactionEntity]) -> [Transaction]`
  - Maps array, filtering out any that fail

### Mapping details:
- `side`: `entity.side` -> `TransactionSide(rawValue:)`
- `status`: `entity.status` -> `TransactionStatus(rawValue:)`
- `operationMethod`: `entity.operationMethod` -> `OperationMethod(rawValue:)`
- `operationType`: `entity.operationType` -> `OperationType(rawValue:)`
- `activityTag`: `entity.activityTag` -> `ActivityTag(rawValue:)`
- `descriptionText` on entity maps to/from `description` on domain model

## Acceptance Criteria
- File exists in `Data/Mappers/`
- Bidirectional mapping: Domain <-> Entity
- Round-trip produces identical data (domain -> entity -> domain == original)
- Handles optional fields correctly
- No force unwraps
- File compiles successfully

## Constraints
- Do NOT put mapping logic on domain types or entity types
- Do NOT add DTO mapping here (that's TASK-007)

## Dependencies
- TASK-002 (domain models)
- TASK-006 (SwiftData entity)
