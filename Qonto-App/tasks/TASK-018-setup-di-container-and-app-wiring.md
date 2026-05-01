# TASK-018: Set Up DI Container and App Wiring

## Goal
Create the dependency injection container and wire everything together in the app entry point.

## Context
Phase 4: Presentation. This is the final wiring step — all layers are connected, and the app becomes runnable.

## Requirements

### 1. Create `App/DIContainer.swift`:
- Struct `DIContainer`
- Creates and holds all dependencies:
  - `HTTPClientProtocol` -> `URLSessionHTTPClient`
  - `TransactionRemoteDataSourceProtocol` -> `TransactionRemoteDataSource`
  - `TransactionLocalDataSourceProtocol` -> `TransactionLocalDataSource`
  - `TransactionRepositoryProtocol` -> `TransactionRepository`
  - `FetchTransactionsUseCaseProtocol` -> `FetchTransactionsUseCase`
  - `TransactionListViewModel`
- Takes `ModelContainer` as input (provided by the app)
- Exposes `viewModel` (or a factory for it) to the app

### 2. Update `App/Qonto_AppApp.swift`:
- Set up `ModelContainer` for `TransactionEntity`
- Create `DIContainer` with the container
- Pass ViewModel to `TransactionListView`
- Use `.modelContainer()` modifier on the window group

## Acceptance Criteria
- `DIContainer.swift` exists in `App/`
- All dependencies wired through protocols (not concrete types in consumers)
- `Qonto_AppApp` creates the container and passes ViewModel to the root view
- App launches successfully and shows the transaction list screen
- SwiftData model container is properly configured
- No singletons or global state — everything flows through DI

## Constraints
- Do NOT use a DI framework
- Do NOT create singletons
- Keep it simple — this is manual constructor injection

## Dependencies
- All previous tasks (001-017) must be complete
