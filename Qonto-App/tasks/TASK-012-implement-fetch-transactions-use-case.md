# TASK-012: Implement Fetch Transactions Use Case

## Goal
Create the use case that orchestrates fetching transactions through the repository.

## Context
Phase 2: Domain Layer. The use case is the entry point for the ViewModel into the domain. It delegates to the repository protocol and returns domain models.

## Requirements
Create `Domain/UseCases/FetchTransactionsUseCase.swift`:

### Protocol: `FetchTransactionsUseCaseProtocol`
- `func execute(page: Int, results: Int) async throws -> [Transaction]`
- `func clearCache() async throws`
- Protocol must be `Sendable`

### Implementation: `FetchTransactionsUseCase`
- Depends on `TransactionRepositoryProtocol` (injected via init)
- `execute(page:results:)`: Forwards to `repository.fetchTransactions(page:results:)`
- `clearCache()`: Forwards to `repository.clearCache()`

**Note:** The use case is intentionally thin for this app. Its value is:
1. Providing a testable boundary between ViewModel and Repository
2. Being the place where cross-cutting business rules would go if needed later
3. Keeping the ViewModel from depending directly on the repository

## Acceptance Criteria
- Protocol + implementation exist in `Domain/UseCases/`
- Only depends on `TransactionRepositoryProtocol` (domain protocol)
- No imports of SwiftData, networking, or UI
- Forwards all calls to the repository
- File compiles successfully

## Constraints
- Do NOT add pagination state management here (that's the ViewModel's job)
- Do NOT import Data layer types
- Keep it simple — this is a pass-through for now

## Dependencies
- TASK-002 (domain models)
- TASK-011 (repository protocol)
