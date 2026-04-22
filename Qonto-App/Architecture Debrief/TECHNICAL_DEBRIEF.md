# Technical Debrief

## 1. Personal Context

I approached this skills test in a relaxed state with no particular time pressure. I had the flexibility to plan thoroughly before writing any code, which allowed me to think through the architecture upfront rather than iterating toward it reactively.

**Environment & tools:**
- Xcode 26 on macOS
- iOS 26 target, Swift 6.2
- No third-party dependencies — everything is built with Apple frameworks (SwiftUI, SwiftData, Network, Foundation)
- Git for version control with a structured branching strategy

---

## 2. Architecture and Main Components

The app follows **Clean Architecture combined with MVVM**, organized into four distinct layers. Each layer has a clear responsibility and a well-defined boundary.

> For detailed diagrams (overview, data flow, sequence diagram, folder structure), see [`ARCHITECTURE_DIAGRAM.md`](ARCHITECTURE_DIAGRAM.md).

### Layer overview

| Layer | Responsibility | Key types |
|-------|---------------|-----------|
| **Core** | Infrastructure — networking, persistence, error types | `URLSessionHTTPClient`, `SwiftDataPersistenceService`, `PersistenceController`, `NetworkMonitor` |
| **Domain** | Business logic — models, use cases, repository contract | `Transaction`, `FetchTransactionsUseCase`, `TransactionRepositoryProtocol`, `FetchResult` |
| **Data** | Data coordination — repository, mappers, data sources | `TransactionRepository`, `TransactionDTOMapper`, `TransactionEntityMapper`, remote/local data sources |
| **UI** | Presentation — views and view models | `TransactionListView`, `TransactionListViewModel`, `TransactionRowView`, `TransactionRowViewModel` |

### Dependency direction

```
UI ──▶ Domain ◀── Data ──▶ Core ──▶ (REST API, SwiftData)
```

The **Domain layer has zero dependencies** on Data or Core. It defines the `TransactionRepositoryProtocol` as an abstract port. The concrete `TransactionRepository` in the Data layer implements that port — this is classic **dependency inversion**.

### Composition root

`DIContainer` is the single place where all layers are wired together through constructor injection. No singletons, no service locators, no global state.

---

## 3. How Components Interact

### Online flow (network-first)

1. `TransactionListViewModel` calls `FetchTransactionsUseCase.execute(page:results:)`
2. The use case delegates to `TransactionRepositoryProtocol.fetchTransactions(page:results:)`
3. The concrete `TransactionRepository` fetches from `TransactionRemoteDataSource` (REST API)
4. `TransactionDTOMapper` converts the JSON-decoded `TransactionDTO` array into domain `[Transaction]`
5. `TransactionEntityMapper` converts domain models to `TransactionEntity` and saves to SwiftData (non-fatal if it fails)
6. The domain array is returned as `FetchResult.fresh`

### Offline fallback (page 1 only)

When the remote fetch fails on **page 1**, the repository checks SwiftData for cached entities:

1. `TransactionLocalDataSource.fetchAll()` retrieves cached `TransactionEntity` records
2. `TransactionEntityMapper` converts them back to domain `[Transaction]`
3. Returned as `FetchResult.cached` — the ViewModel uses this to show data while the `NetworkMonitor` displays a "No Internet" banner

Paginated requests (page > 1) that fail do **not** fall back to cache — they fail silently, keeping existing data on screen.

### Real-time connectivity

`NetworkMonitor` wraps `NWPathMonitor` and is `@Observable`. The view observes `isConnected` directly to show/hide the offline banner with animation. The monitor is owned by `DIContainer` and passed as a concrete type to the view (not through the ViewModel) because SwiftUI's observation tracking doesn't work through existential types (`any Protocol`).

---

## 4. Good Practices Applied

### SOLID Principles

- **Single Responsibility**: Each type has one job. Mappers only map. Data sources only fetch/persist. The ViewModel only manages UI state. The repository only coordinates remote vs. local.
- **Open/Closed**: `SwiftDataPersistenceService` works with any type conforming to `Persistable` via generics. When we added `TransactionEntity`, we didn't modify the service — we just made the entity conform to `Persistable`. The service is closed for modification but open for extension through new conforming types.
- **Liskov Substitution**: All protocol conformances are interchangeable. Tests use mocks (`MockFetchTransactionsUseCase`, `MockTransactionLocalDataSource`, etc.) that substitute seamlessly.
- **Interface Segregation**: `TransactionLocalDataSourceProtocol` exposes only 4 focused methods (`fetchAll`, `save`, `deleteAll`, `hasData`) — exactly what the repository needs. It doesn't leak the full generic CRUD surface of `PersistenceServicing` to its consumers. Each protocol is scoped to its caller's actual needs.
- **Dependency Inversion**: The Domain layer defines abstract protocols (`TransactionRepositoryProtocol`, `FetchTransactionsUseCaseProtocol`). Concrete implementations live in outer layers. All dependencies are injected through initializers.

### Design Patterns

- **Repository Pattern**: `TransactionRepository` coordinates between remote and local data sources, encapsulating the network-first + offline fallback strategy.
- **Mapper Pattern**: Dedicated mapper types (`TransactionDTOMapper`, `TransactionEntityMapper`) keep conversion logic out of models and data sources.
- **Composition Root**: `DIContainer` assembles the entire object graph in one place.

### KISS — Keep It Simple

- Three view states (`.loading`, `.loaded`, `.error`) instead of a complex state machine. Pagination and refresh failures are silent when data exists — no alerts, no inline error views, just sensible defaults. All silent failures are logged via `QontoLogger` (OSLog) so they remain observable in Console.app without impacting the user.
- No Combine, no reactive chains. Pure `async/await` everywhere.
- No third-party dependencies. Apple frameworks handle everything needed.

### DRY — Don't Repeat Yourself

- `PersistenceServicing` is a generic persistence abstraction — any `Persistable` type can use it without duplicating CRUD logic.
- `FetchResult` enum centralizes the fresh-vs-cached distinction instead of scattering boolean flags.
- Mapper types are reused by both the repository (online path) and the cache fallback (offline path).

### Modern Swift

- `@Observable` + `@State` for SwiftUI observation (no `ObservableObject`/`@Published`)
- `async/await` throughout — no closures, no completion handlers, no Combine
- SwiftData for persistence (not Core Data)
- Swift Testing framework for unit tests (`#expect`, `@Test`, parameterized tests)
- Typed throws where appropriate (`throws(NetworkError)`, `throws(MappingError)`)
- Strict Swift 6 concurrency (`@MainActor` isolation, `Sendable` conformance)

---

## 5. Development Strategy

### Phase-based approach

The project was broken into **23 ordered tasks** across 6 phases:

| Phase | Tasks | Focus |
|-------|-------|-------|
| 1 — Foundation | TASK-001 to TASK-004 | Folder structure, domain models, networking, persistence |
| 2 — Data Layer | TASK-005 to TASK-010 | DTOs, entity, mappers, remote/local data sources |
| 3 — Domain | TASK-011 to TASK-012 | Repository protocol, use case |
| 4 — Repository | TASK-013 | Concrete repository wiring remote + local |
| 5 — Presentation | TASK-014 to TASK-018 | ViewModel, views, DI container |
| 6 — Testing & Polish | TASK-019 to TASK-023 | Unit tests, manual testing, debrief |

### Why this order

I built **bottom-up**: infrastructure first, then data layer, then domain, then UI. This meant:
- Each layer could be built and tested against the layer below it
- No placeholder code or temporary stubs were needed
- Dependencies were always ready before the code that uses them

### What I favored

- **Correctness over speed**: I invested time in proper protocol abstractions and mapper separation rather than taking shortcuts that would make the code harder to test or extend.
- **Testability**: Every boundary is behind a protocol, which made writing unit tests straightforward with simple mock implementations.
- **Simplicity in error handling**: I deliberately simplified from a complex 5-state UI to 3 states. Pagination and refresh errors fail silently when data exists. This keeps the UX clean without sacrificing reliability.

---

## 6. Unit Testing Strategy

### Approach

Unit tests focus on the **logic-heavy boundaries** — the layers where data transforms, state changes, and decisions happen. Views are not unit tested; they are validated through manual testing and Xcode Previews.

All tests use the **Swift Testing** framework (`@Test`, `#expect`, `@Suite`) and run with `@MainActor` isolation to match production code.

### What is covered

| Test suite | What it tests | Key scenarios |
|------------|--------------|---------------|
| **TransactionDTOMapperTests** | DTO → Domain mapping | Amount parsing (valid/invalid), ISO 8601 date parsing, all enum mappings via parameterized tests, optional field handling, invalid DTO filtering in arrays |
| **TransactionEntityMapperTests** | Entity ↔ Domain bidirectional mapping | Round-trip accuracy, optional fields, page field preservation, invalid enum values default gracefully, array filtering for invalid entities |
| **TransactionListViewModelTests** | ViewModel state transitions and pagination logic | Initial load (loading → loaded), error state on failure, pagination (append, dedup, guard against concurrent loads, hasMorePages), refresh (resets page, cached result keeps existing data, silent failure with data), `onTransactionAppear` threshold trigger |
| **TransactionRepositoryTests** | Repository coordination between remote and local | Network-first happy path, page 1 clears cache before save, page 2+ appends without clearing, cache save failure is non-fatal, offline fallback returns cached data on page 1, offline page 2+ throws, mapping correctness through the full pipeline |

### Mock strategy

All mocks live in a dedicated `Mocks/` folder and are reused across test suites:

- **`MockFetchTransactionsUseCase`** — configurable result or error, tracks call count and last parameters
- **`MockTransactionRemoteDataSource`** — returns a configurable `TransactionResponse` or throws
- **`MockTransactionLocalDataSource`** — in-memory storage, tracks all method calls, can be configured to throw on specific operations

Mocks are injected through the same initializers used in production (`DIContainer`), so test wiring mirrors real wiring exactly.

---

## 7. Commit Strategy

- **One branch per task**: e.g., `TASK-014-implement-transaction-list-viewmodel`
- **Merge into `feature/qonto-test`** after review and approval
- **Descriptive commit messages** that explain what was done: `"TASK-013: Implement TransactionRepository with network-first strategy and offline fallback"`
- **No squashing**: each commit represents a logical, reviewable unit of work
- **Master task file** updated after each merge to track progress

This approach means any reviewer can look at a single branch/commit and understand exactly what changed and why, without needing context from other tasks.

---

## 8. Future-Proofing and Scalability

The code is future-proof because every layer is **isolated behind clear boundaries** with no cross-contamination. The architecture was designed so that any layer, framework, or implementation detail can be swapped without ripple effects.

### Layer isolation — each layer is a potential package

- **Domain** is completely isolated. It imports nothing from Data, Core, or UI — only Foundation. It could be extracted into a standalone Swift Package today with zero changes. This means the business logic is reusable across targets (iOS, watchOS, macOS) and is immune to infrastructure decisions.

- **Data, Core, and UI** each depend only on the layer directly below them (or on Domain). They could each be moved to separate Swift Packages with minimal changes — just adding `import DomainPackage` at the top.

### Abstractions make implementations swappable

Every infrastructure detail is hidden behind a protocol:

| Protocol | Current implementation | Could be replaced with |
|----------|----------------------|----------------------|
| `NetworkServicing` | `URLSessionHTTPClient` | Alamofire, custom HTTP stack |
| `PersistenceServicing` | `SwiftDataPersistenceService` | Core Data, Realm, SQLite |
| `TransactionRemoteDataSourceProtocol` | REST API fetch | GraphQL, WebSocket, gRPC |
| `TransactionLocalDataSourceProtocol` | SwiftData queries | Core Data fetch requests, in-memory cache |
| `TransactionRepositoryProtocol` | Network-first + cache | Cache-first, sync engine, any strategy |
| `FetchTransactionsUseCaseProtocol` | Direct repository call | Add caching rules, analytics, rate limiting |

For example, replacing SwiftData with Core Data means writing a new `CoreDataPersistenceService` that conforms to `PersistenceServicing`. Nothing in the Data layer, Domain layer, or UI layer changes. The swap happens in one line inside `DIContainer`.

### Constructor injection enables this

Because all dependencies flow through `DIContainer` via initializer parameters, there are no hidden couplings. No singleton access, no `shared` instances, no framework imports leaking across layers. This also makes every component independently testable — all unit tests use mock implementations injected through the same initializers.

### What I intentionally kept simple

- **No date-based grouping** in the transaction list — the flat list is sufficient for the scope and avoids premature complexity
- **No empty state view** — an empty list in `.loaded` state is clear enough; adding a dedicated view would add a state to manage
- **`try!` on `ModelContainer` creation** — this is a programmer error if it fails (schema mismatch), not a runtime condition to recover from

---

## 9. AI-Assisted Development

I used Claude as a **structured engineering assistant** — not as a code generator. The workflow was: spec first, plan second, then execute one task at a time with approval gates between each step. Every AI output was reviewed, and corrections were tracked in `AGENT_REVIEW.md`. The AI operated within strict constraints: no jumping ahead, no redesigning the plan, no merging tasks.

For full details on the prompting strategy, concrete examples of corrections (architecture violations, offline strategy fixes, over-engineering removal), and the control principles applied, see [`AGENTIC_AI_USAGE.md`](../AGENTIC_AI_USAGE.md).

---

## Summary

This project demonstrates a clean, testable, and production-ready architecture for a transaction list feature. The key decisions — Clean Architecture with MVVM, protocol-based DI, network-first with offline fallback, and a simplified error UX — were all made deliberately to balance engineering rigor with practical simplicity. Every component can be tested in isolation, extended without modifying existing code, and explained clearly in a technical discussion.
