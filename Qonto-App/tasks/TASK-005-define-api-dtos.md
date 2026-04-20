# TASK-005: Define API DTOs

## Goal
Create all Codable DTO structs that represent the raw JSON response from the transactions API.

## Context
Phase 2: Data Layer. DTOs are the first Data layer types. They mirror the API response exactly and are used by the remote data source for JSON decoding.

## Requirements
Create `Data/DTOs/TransactionResponse.swift` containing:

### `TransactionResponse` (Codable, Sendable)
- `results`: [TransactionDTO]
- `info`: InfoDTO

### `TransactionDTO` (Codable, Sendable)
- `id`: String
- `amount`: AmountDTO
- `counterpartyName`: String
- `emittedAt`: String
- `settledAt`: String?
- `side`: String
- `status`: String
- `operationMethod`: String
- `operationType`: String
- `description`: String
- `activityTag`: String
- `note`: String?
- `initiator`: InitiatorDTO?
- `bankAccount`: BankAccountDTO

### `AmountDTO` (Codable, Sendable)
- `value`: String
- `currency`: String

### `InitiatorDTO` (Codable, Sendable)
- `id`: String
- `fullName`: String

### `BankAccountDTO` (Codable, Sendable)
- `id`: String
- `name`: String

### `InfoDTO` (Codable, Sendable)
- `seed`: String
- `results`: Int
- `page`: Int
- `version`: String

## Acceptance Criteria
- All DTOs defined in `Data/DTOs/TransactionResponse.swift`
- All types conform to `Codable` and `Sendable`
- Property names match API JSON keys exactly (for automatic decoding)
- Optional fields (`settledAt`, `note`, `initiator`) are correctly optional
- File compiles successfully

## Constraints
- Do NOT add mapping logic (that's TASK-007)
- Do NOT import Domain layer types
- Do NOT use enums in DTOs — keep as raw Strings to match API

## Dependencies
- TASK-001 (folder structure)
