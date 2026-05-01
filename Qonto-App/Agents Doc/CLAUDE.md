# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

iOS app that displays a paginated list of transactions from a Qonto staging API, with offline access via SwiftData cache. Single Xcode project, no third-party dependencies — Apple frameworks only (SwiftUI, SwiftData, Network, Foundation, OSLog). iOS 26.4 deployment target, Swift 6 with strict concurrency.

The Xcode project lives one level up at `Qonto-App.xcodeproj`. The application source is under `Qonto-App/` and tests under `Qonto-AppTests/`. The folder groups are file-system synchronized (`PBXFileSystemSynchronizedRootGroup`), so newly added Swift files are picked up automatically — no `pbxproj` edits required.

## Build / test / run

All commands assume CWD is the repo root containing `Qonto-App.xcodeproj`.

```bash
# Build for the iOS Simulator
xcodebuild -project Qonto-App.xcodeproj -scheme Qonto-App \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests (Swift Testing framework)
xcodebuild -project Qonto-App.xcodeproj -scheme Qonto-App \
  -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test suite or single test
xcodebuild ... test -only-testing:Qonto-AppTests/TransactionListViewModelTests
xcodebuild ... test -only-testing:Qonto-AppTests/TransactionListViewModelTests/loadInitialTransactions_setsLoadedState
```

There is one shared scheme (`Qonto-App`). Tests use the **Swift Testing** framework (`@Test`, `#expect`, `@Suite`) — not XCTest. Tests run `@MainActor`-isolated to match production isolation.

## Architecture

Clean Architecture + MVVM in four layers. The dependency rule is strict: outer layers depend on inner layers, never the reverse.

```
UI ──▶ Domain ◀── Data ──▶ Core ──▶ (REST API, SwiftData)
```

| Layer | Path | Responsibility |
|-------|------|----------------|
| **UI** | `Qonto-App/UI/` | SwiftUI views and `@Observable` view models |
| **Domain** | `Qonto-App/Domain/` | `Transaction` model, `FetchResult`, use cases, repository **protocol** |
| **Data** | `Qonto-App/Data/` | `TransactionRepository` (concrete), DTOs, mappers, remote/local data sources |
| **Core** | `Qonto-App/Core/` | `URLSessionHTTPClient`, `SwiftDataPersistenceService`, `NetworkMonitor`, `QontoLogger` |

The Domain layer imports only `Foundation`. It owns the `TransactionRepositoryProtocol` port; the Data layer implements it (dependency inversion). Don't add `import` statements that reverse this direction.

### Composition root — `App/DIContainer.swift`

Every dependency is wired here via constructor injection. There are **no singletons, no `.shared`, no service locators, no global state**. The full graph is built once in `Qonto_AppApp` and passed into `TransactionListView`. When adding a new service, extend `DIContainer.init` rather than introducing a new global access point.

### Online vs offline behavior — `Data/Repositories/TransactionRepository.swift`

Network-first with offline fallback **only on page 1**:

1. Call `TransactionRemoteDataSource` → map DTOs to domain → return `FetchResult.fresh`
2. After a successful fetch, write through to SwiftData via `TransactionLocalDataSource`. Page 1 calls `deleteAll()` first; pages 2+ append (with old-page eviction keeping the most recent 5 pages).
3. If the remote fetch fails:
   - **Page 1**: load from cache → return `FetchResult.cached`. The ViewModel keeps the data on screen and the `NetworkMonitor` shows the offline banner.
   - **Page 2+**: rethrow. The ViewModel logs and silently keeps existing data on screen — no error UI.

Cache write failures are non-fatal — they're logged via `QontoLogger.warning` and the fresh data is still returned. Preserve this "fail silently when data exists" pattern when changing error handling; alerts/inline errors during pagination or refresh have been deliberately avoided.

### Persistence concurrency model

`SwiftDataPersistenceService`, `TransactionLocalDataSource`, and `PersistenceServicing` are all `@MainActor`-isolated because SwiftData's `ModelContext` is not `Sendable` and the `ModelContainer` is created on the main actor. Saves rely on SwiftData's `autosaveEnabled` default — there is no explicit `save()` call. The trade-off (a crash before the next runloop checkpoint could lose the most recent batch) is intentional: the cache is repopulated on every successful fetch.

If you need background persistence (large writes, complex graphs), introduce a `@ModelActor` rather than reaching across actors with `nonisolated` shortcuts.

### Networking

- `APIEndpoint` builds requests against `https://us-central1-qonto-staging.cloudfunctions.net/transactions` with a hardcoded `seed: "qonto"`.
- `NetworkMonitor` wraps `NWPathMonitor` and is `@Observable`. It is passed as a **concrete type** (not `any NetworkMonitoring`) into `TransactionListView` because SwiftUI's observation tracking does not work through existential types.

### ViewModel state model — `UI/TransactionList/TransactionListViewModel.swift`

Three view states only: `.loading`, `.loaded`, `.error(String)`. Pagination triggers when the user scrolls within 5 rows of the end (`onTransactionAppear` → `loadMoreTransactions`). The ViewModel guards against concurrent loads with `isLoadingMore` and stops paginating when a page returns fewer than `pageSize` (30) results or when all returned IDs were already present.

## Conventions

- **No `import` reversal across layers.** Domain ↛ Data, Domain ↛ Core, Domain ↛ UI.
- **Mappers, not models, do conversion.** Add new mapping logic to `Data/Mappers/`. Don't put DTO/Entity knowledge inside `Transaction`.
- **Every external boundary is behind a protocol.** When adding a new external dependency (HTTP, persistence, etc.), define a `…Protocol` in the appropriate layer and inject the concrete type via `DIContainer`.
- **Modern Swift only.** `@Observable` (not `ObservableObject`/`@Published`), `async/await` (no Combine, no completion handlers), Swift Testing (no XCTest), typed throws where it adds value (`throws(NetworkError)`, `throws(MappingError)`).
- **Logging.** Non-fatal failures go through `QontoLogger.warning(_:caller:)`. The category is the caller type, the subsystem is `com.qonto`.
- **Tests live in `Qonto-AppTests/`**, mocks in `Qonto-AppTests/Mocks/`. Mocks are injected via the same initializers `DIContainer` uses, so test wiring mirrors production wiring.

## Reference docs in this repo

- `Architecture/ARCHITECTURE_DIAGRAM.md` — Mermaid diagrams for layer overview, online/offline data flow, and a refresh sequence diagram.
- `README.md` — full rationale for architecture, persistence concurrency, error UX, and future-proofing decisions.
- `tasks/MASTER_TASK.md` and `tasks/TASK-*.md` — the 23-task implementation plan the project was built against.
