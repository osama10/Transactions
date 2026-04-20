# TASK-019: Write Unit Tests for Mappers

## Goal
Write unit tests for `TransactionDTOMapper` and `TransactionEntityMapper` to verify correct data transformation.

## Context
Phase 5: Testing. Mappers are pure functions with no side effects — ideal for unit testing. These tests validate the data boundary between layers.

## Requirements
Create test files in `Qonto-AppTests/`:

### 1. `TransactionDTOMapperTests.swift`
Tests for `TransactionDTOMapper.mapToDomain(dto:)`:

- **Happy path:** Complete DTO with all fields -> correct Transaction
- **Amount parsing:** String "1234.56" -> Decimal 1234.56
- **Date parsing:** ISO 8601 string -> correct Date
- **Enum mapping:** Each string value maps to the correct enum case
  - "CREDIT" -> .credit, "DEBIT" -> .debit
  - "COMPLETED" -> .completed, "PENDING" -> .pending, "DECLINED" -> .declined
  - "TRANSFER" -> .transfer, "CARD" -> .card, "DIRECT_DEBIT" -> .directDebit
  - "INCOME" -> .income, etc.
- **Optional nil handling:** settledAt = nil, note = nil, initiator = nil -> mapped correctly
- **Optional present handling:** settledAt, note, initiator all present -> mapped correctly
- **Initiator flattening:** initiator.fullName -> initiatorName
- **Bank account flattening:** bankAccount.name -> bankAccountName
- **Invalid DTO:** Unparseable amount or date -> returns nil (defensive)
- **Array mapping:** Mix of valid and invalid DTOs -> only valid ones returned

### 2. `TransactionEntityMapperTests.swift`
Tests for bidirectional mapping:

- **Domain -> Entity:** All fields correctly mapped, enums stored as rawValue
- **Entity -> Domain:** All fields correctly reconstructed, enums rebuilt
- **Round-trip:** domain -> entity -> domain == original
- **Optional handling:** nil fields survive round-trip
- **Page field:** page parameter correctly set on entity
- **Invalid entity:** Entity with bad enum rawValue -> returns nil

## Acceptance Criteria
- Test files exist in `Qonto-AppTests/`
- Use the Swift Testing framework (`import Testing`)
- All tests pass
- Cover happy path, edge cases, and error cases
- No test doubles needed (mappers are pure functions)

## Constraints
- Do NOT test SwiftData persistence (that's TASK-021)
- Do NOT use XCTest — use Swift Testing framework
- Keep tests focused on mapping logic only

## Dependencies
- TASK-007 (DTO mapper)
- TASK-008 (entity mapper)
