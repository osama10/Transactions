# TASK-011: Define Repository Protocol

## Goal
Create the repository protocol in the Domain layer that defines the contract for fetching transactions.

## Context
Phase 2: Domain Layer. The repository protocol is the boundary between Domain and Data. The Domain layer defines it; the Data layer implements it.

## Requirements
Create `Domain/Repositories/TransactionRepositoryProtocol.swift`:

### `TransactionRepositoryProtocol`
- Protocol, `Sendable`
- `func fetchTransactions(page: Int, results: Int) async throws -> [Transaction]`
  - Returns domain models (not DTOs, not entities)
  - The implementation handles remote fetch, local fallback, mapping, and caching internally
- `func clearCache() async throws`
  - Clears all locally stored transactions (e.g. for pull-to-refresh)

## Acceptance Criteria
- File exists in `Domain/Repositories/`
- Protocol defines all methods needed by the use case
- Only references domain types (`Transaction`) — no DTOs, no entities
- No framework imports beyond Foundation
- File compiles successfully

## Constraints
- Do NOT implement the protocol here (that's TASK-013)
- Do NOT import SwiftData or networking types
- Keep the protocol focused — only what the use case needs

## Dependencies
- TASK-002 (domain models — `Transaction`)
