# Implementation Plan - Qonto Transactions App

---

## 1. Requirements Analysis

### Product Goal
A single-screen iOS app that fetches paginated banking transactions from a REST API and displays them in a scrollable list, with offline support via local persistence.

### API Summary
- **Endpoint:** `GET /transactions`
- **Base URL:** `https://us-central1-qonto-staging.cloudfunctions.net/transactions`
- **Query params:** `results` (1-100, default 10), `page` (1-10000, default 1), `seed` (string, for deterministic data)
- **Response:** `{ results: [Transaction], info: { seed, results, page, version } }`
- **No authentication required**
- **No total count provided** — the API does not tell us when we've reached the last page

### Core Requirements
1. Fetch and display transactions in a scrollable list
2. Paginate — load next page on scroll, no duplicates, no redundant fetches
3. Offline access — persist fetched transactions locally (SwiftData)
4. Handle loading, empty, error, and offline states
5. Technical debrief document

---

## 2. Architecture: Clean Architecture + MVVM

```
┌─────────────────────────────────┐
│        UI (Presentation)        │
│   Views + ViewModels            │
├─────────────────────────────────┤
│           Domain                │
│   Models + Use Cases +          │
│   Repository Protocols          │
├─────────────────────────────────┤
│            Data                 │
│   Repository Impl + DTOs +     │
│   Data Sources                  │
├─────────────────────────────────┤
│            Core                 │
│   Networking + Persistence      │
└─────────────────────────────────┘
```

### Why this architecture
- Clean separation of concerns — each layer has one job
- Testable — domain layer has no framework dependencies
- Easy to explain in an interview — "data flows up, dependencies point inward"
- Not over-engineered — only the layers we actually need

---

## 3. Layer Definitions

### 3.1 Presentation Layer (UI/)
- **Responsibility:** Render UI, handle user interactions, observe ViewModel state
- **Contains:** SwiftUI Views, ViewModels (`@Observable`), UI-specific types (e.g., view state enums)
- **Rules:** Views are dumb — they read state and send actions. ViewModels orchestrate use cases and manage UI state, but do not contain core business rules (which belong to the domain layer).

### 3.2 Domain Layer (Domain/)
- **Responsibility:** Define business models, repository protocols, and use cases
- **Contains:** `Transaction` (domain model), `TransactionRepositoryProtocol`, `FetchTransactionsUseCase`
- **Rules:** No imports of SwiftData, Foundation networking, or UI frameworks. Pure Swift types and protocols.

### 3.3 Data Layer (Data/)
- **Responsibility:** Implement repository protocols, coordinate between remote and local data sources, map DTOs to domain models
- **Contains:** `TransactionRepository` (concrete), API DTOs (`TransactionResponse`, `TransactionDTO`), SwiftData entities (`TransactionEntity`), mappers
- **Rules:** Knows about both Core and Domain. Orchestrates data flow between network and persistence.

### 3.4 Core Layer (Core/)
- **Responsibility:** Provide infrastructure — HTTP client, SwiftData stack
- **Contains:** `HTTPClient` protocol + `URLSessionHTTPClient`, `PersistenceController` (SwiftData container setup)
- **Rules:** Framework-level code only. No business logic. No domain knowledge.

---

## 4. Data Models

### 4.1 API Models (Data/DTOs/)

**`TransactionResponse`** — top-level API response
| Field   | Type               |
|---------|--------------------|
| results | [TransactionDTO]   |
| info    | InfoDTO            |

**`TransactionDTO`** — raw API transaction
| Field            | Type         | Notes                          |
|------------------|--------------|--------------------------------|
| id               | String       | UUID string                    |
| amount           | AmountDTO    | nested { value, currency }     |
| counterpartyName | String       |                                |
| emittedAt        | String       | ISO 8601                       |
| settledAt        | String?      | null if not completed (API: "null if not completed") |
| side             | String       | "CREDIT" or "DEBIT"            |
| status           | String       | "COMPLETED", "PENDING", "DECLINED" |
| operationMethod  | String       | "TRANSFER", "CARD", "DIRECT_DEBIT" |
| operationType    | String       | "INCOME", "TRANSFER", "CARD"   |
| description      | String       |                                |
| activityTag      | String       | category tag                   |
| note             | String?      | API: "~20% chance of being set" |
| initiator        | InitiatorDTO?| API: "~70% chance of being set" |
| bankAccount      | BankAccountDTO |                              |

**`AmountDTO`** — `{ value: String, currency: String }`
**`InitiatorDTO`** — `{ id: String, fullName: String }`
**`BankAccountDTO`** — `{ id: String, name: String }`
**`InfoDTO`** — `{ seed: String, results: Int, page: Int, version: String }`

### 4.2 Domain Models (Domain/Models/)

**`Transaction`** — clean business model
| Field            | Type                    |
|------------------|------------------------|
| id               | String                 |
| counterpartyName | String                 |
| amount           | Decimal                |
| currency         | String                 |
| emittedAt        | Date                   |
| settledAt        | Date?                  |
| side             | TransactionSide        |
| status           | TransactionStatus      |
| operationMethod  | OperationMethod        |
| operationType    | OperationType          |
| description      | String                 |
| activityTag      | ActivityTag            |
| note             | String?                |
| initiatorName    | String?                |
| bankAccountName  | String                 |

**Enums** (all `String`-backed, `Sendable`, `Hashable`):
- `TransactionSide`: `.credit`, `.debit`
- `TransactionStatus`: `.completed`, `.pending`, `.declined`
- `OperationMethod`: `.transfer`, `.card`, `.directDebit`
- `OperationType`: `.income`, `.transfer`, `.card`
- `ActivityTag`: `.otherIncome`, `.otherExpense`, `.otherService`, `.refund`, `.fees`

### 4.3 Database Models (Data/Local/)

**`TransactionEntity`** — SwiftData `@Model`
| Field            | Type    | Notes                            |
|------------------|---------|----------------------------------|
| id               | String  | primary key (unique identifier)  |
| counterpartyName | String  |                                  |
| amount           | Decimal |                                  |
| currency         | String  |                                  |
| emittedAt        | Date    |                                  |
| settledAt        | Date?   |                                  |
| side             | String  | raw value of enum                |
| status           | String  | raw value of enum                |
| operationMethod  | String  | raw value of enum                |
| operationType    | String  | raw value of enum                |
| descriptionText  | String  | avoid `description` collision    |
| activityTag      | String  | raw value of enum                |
| note             | String? |                                  |
| initiatorName    | String? | flattened from nested object     |
| bankAccountName  | String  | flattened from nested object     |
| page             | Int     | track which page this came from  |

### 4.4 Mapping Strategy

```
API (DTO) ──mapper──> Domain (Transaction) ──mapper──> SwiftData (Entity)
                                                  and
SwiftData (Entity) ──mapper──> Domain (Transaction)
```

- **DTO -> Domain:** Parse ISO 8601 dates, convert amount string to Decimal, map string enums to Swift enums, flatten nested objects (initiator.fullName -> initiatorName)
- **Domain -> Entity:** Direct field-to-field, enums stored as rawValue strings
- **Entity -> Domain:** Reconstruct enums from rawValue, direct field mapping

Mappers live exclusively in the **Data layer** (`Data/Mappers/`). They are standalone structs with static methods (e.g., `TransactionDTOMapper.mapToDomain(dto:) -> Transaction` and `TransactionEntityMapper.mapToEntity(domain:) -> TransactionEntity`). The **Repository** (Data layer) calls these mappers and returns clean domain models. The Domain layer never imports or knows about DTOs or Entities — it only defines the models and repository protocols.

---

## 5. Folder Structure

```
Qonto-App/
├── Core/
│   ├── Networking/
│   │   ├── HTTPClient.swift              # Protocol
│   │   ├── URLSessionHTTPClient.swift    # Implementation
│   │   ├── APIEndpoint.swift             # URL construction
│   │   └── NetworkError.swift            # Error types
│   └── Persistence/
│       └── PersistenceController.swift   # SwiftData container setup
│
├── Domain/
│   ├── Models/
│   │   └── Transaction.swift             # Domain model + enums
│   ├── UseCases/
│   │   └── FetchTransactionsUseCase.swift
│   └── Repositories/
│       └── TransactionRepositoryProtocol.swift
│
├── Data/
│   ├── DTOs/
│   │   └── TransactionResponse.swift     # All DTOs
│   ├── Local/
│   │   ├── TransactionEntity.swift       # SwiftData model
│   │   └── TransactionLocalDataSource.swift
│   ├── Remote/
│   │   └── TransactionRemoteDataSource.swift
│   ├── Mappers/
│   │   ├── TransactionDTOMapper.swift    # DTO -> Domain
│   │   └── TransactionEntityMapper.swift # Domain <-> Entity
│   └── Repositories/
│       └── TransactionRepository.swift   # Concrete implementation
│
├── UI/
│   ├── TransactionList/
│   │   ├── TransactionListView.swift
│   │   ├── TransactionListViewModel.swift
│   │   └── TransactionRowView.swift
│   └── Components/
│       ├── ErrorView.swift
│       ├── EmptyStateView.swift
│       └── LoadingView.swift
│
├── App/
│   ├── Qonto_AppApp.swift               # Entry point + DI
│   └── DIContainer.swift                # Simple dependency assembly
│
├── Assets.xcassets/
└── ...
```

---

## 6. Pagination Strategy

### Approach: Page-number based infinite scroll

1. **Fixed seed:** On first launch, use a fixed seed string (e.g., `"qonto"`) for all requests. This ensures deterministic data across pages and avoids duplicates.
2. **Page size:** Request 30 results per page (`results=30`) — a good balance between network calls and responsiveness.
3. **Trigger:** When the user scrolls and a transaction near the bottom of the list appears on screen (last 5 items threshold), trigger loading the next page.
4. **State tracking:** The ViewModel tracks `currentPage` (Int) and `isLoadingMore` (Bool) and `hasMorePages` (Bool).
5. **Duplicate prevention:** Since we use a fixed seed, same page always returns same data. Deduplicate by `transaction.id` before appending.
6. **End detection:** Since the API has no total count, two checks are used:
   - If a page returns fewer results than requested (< pageSize), set `hasMorePages = false`
   - If the API continues returning full pages, detect termination by checking for duplicate-only pages (no new transaction IDs)
7. **Guard against redundant fetches:** If `isLoadingMore` is true or `hasMorePages` is false, skip the fetch.

### Flow
```
User scrolls near bottom
  -> ViewModel checks: !isLoadingMore && hasMorePages 
  -> Yes: set isLoadingMore = true, fetch page (currentPage + 1) via use case
  -> Receive results: append to list, save to SwiftData, increment currentPage
  -> If results.count < pageSize OR all IDs already exist: set hasMorePages = false
  -> Set isLoadingMore = false
```

---

## 7. Offline Strategy

### Source of Truth
- The app follows a **network-first strategy**: always attempt the API first, fall back to local cache on failure.
- **Online:** Remote API is the source of truth. Fresh data is fetched, mapped to domain models, and persisted to SwiftData.
- **Offline:** SwiftData is the fallback source of truth. The app displays cached transactions.

### Sync Behavior
1. **On app launch / pull-to-refresh:**
   - Attempt to fetch page 1 from the API
   - **Success:** Replace existing cached data with fresh data, then display it
   - **Failure + cache exists:** Keep existing cached transactions and show a small non-dismissible informational strip below the nav bar (`wifi.slash` icon + "You're viewing cached data. Pull to refresh when back online.")
   - **Failure + no cache:** Show full-screen error state with retry button
2. **On pagination (loading more):**
   - Attempt to fetch next page from API
   - **Success:** Append and persist
   - **Failure:** Show inline error at bottom of list with retry option; keep existing data visible
3. **No background sync** — data is only fetched on user action (launch, scroll, pull-to-refresh)

### Persistence Rules
- Store all fetched transactions in SwiftData with their `page` number
- On fresh fetch (page 1), delete all existing entities before inserting (avoids stale data mixing with new seed data)
- On pagination, upsert new entities: check by `id` — if a transaction with the same `id` already exists, update it; if not, insert it

### Local Storage Cap
- Define a constant `maxCachedPages = 10` (~300 transactions max locally)
- When inserting a new page, if total stored pages exceeds `maxCachedPages`, delete the oldest page's entities (lowest page numbers first)
- On pull-to-refresh, the cap naturally resets since all cached data is cleared before re-fetching
- Page-based eviction keeps complete pages intact for a consistent offline experience

### SwiftData Threading
- All SwiftData operations use `ModelContainer.mainContext` (which is `@MainActor`)
- Inserts, deletes, and fetches all happen on the main actor
- With 30 lightweight objects per page and a 300-item cap, operations are effectively instant — no need for a background `@ModelActor`
- If performance ever becomes a concern (it won't at this scale), this can be migrated to `@ModelActor` later

---

## 8. Error Handling Strategy

### Error Types
```
NetworkError
  - noConnection        // URLError.notConnectedToInternet
  - timeout             // URLError.timedOut
  - serverError(Int)    // HTTP 5xx
  - invalidResponse     // non-200 or decode failure
  - unknown(Error)      // catch-all
```

### UI Error States

| Scenario | State | UI |
|----------|-------|----|
| First load fails, no cache | `.error` | Full-screen error with message + retry button |
| First load fails, cache exists | `.offline` | Show cached list + a small non-dismissible informational strip below the nav bar with `wifi.slash` icon and text: "You're viewing cached data. Pull to refresh when back online." |
| Pagination fails | `.paginationError` | Inline error row at bottom of list with retry |
| Empty response (page 1, 0 results) | `.empty` | Full-screen empty state with a `tray` SF Symbol and explicit message: "No transactions yet" |
| Loading first page | `.loading` | Full-screen loading indicator | 
| Loading more pages | `.loaded` + footer spinner | List visible, spinner at bottom |

### Principles
- Never show a blank screen if we have cached data
- Errors are recoverable — always offer retry
- User-facing messages are friendly, not technical (e.g., "Unable to load transactions. Check your connection and try again.")

---

## 9. UI Approach

### Transaction List Screen

**Navigation bar:** Title "Transactions"

**Each row displays:**
```
┌─────────────────────────────────────────────┐
│ [Icon]  Counterparty Name          +€1,234  │  <- line 1: name + signed/colored amount
│         Card - Office supplies      Pending  │  <- line 2: method + description, status badge
│         15 Jun 2025, 10:30                   │  <- line 3: settled or emitted date
└─────────────────────────────────────────────┘
```

### UI Enhancements (beyond minimum)
1. **Amount color coding:** Green for CREDIT, primary text for DEBIT, with +/- prefix
2. **Status badge:** Colored capsule — green for COMPLETED, orange for PENDING, red for DECLINED
3. **Operation method icon:** SF Symbol per method — `creditcard` for CARD, `arrow.left.arrow.right` for TRANSFER, `building.columns` for DIRECT_DEBIT
4. **Activity tag:** Subtle secondary label or icon to indicate category
5. **Section headers by date:** Group transactions by day (using `emittedAt`) and sort in descending order (most recent first) for better scanability
6. **Pull-to-refresh:** Standard `.refreshable` modifier to reload from page 1. This clears the local cache and re-fetches fresh data from the API, resetting pagination state.
7. **Loading footer:** `ProgressView` shown as last item during pagination
8. **Initiator name:** Show "by Alice Martin" as tertiary info when available 

### View State Enum
```
ViewState:
  .loading              -> ProgressView
  .loaded([Transaction]) -> List
  .empty                -> EmptyStateView
  .error(String)        -> ErrorView with retry
  .offline([Transaction]) -> List + offline banner
```

---

## 10. Dependencies

**None.** Zero third-party dependencies.

- Networking: `URLSession` (built-in)
- Persistence: `SwiftData` (built-in, iOS 17+; we target iOS 26)
- UI: `SwiftUI` (built-in)
- JSON decoding: `JSONDecoder` (built-in)

### Dependency Injection
- Simple manual DI via a `DIContainer` struct created at app launch
- No DI frameworks — the container instantiates concrete types and passes them as protocols
- ViewModels receive use cases via init injection

---

## 11. Testing Strategy

### Unit Tests (primary focus)

| Component | What to test |
|-----------|-------------|
| `TransactionDTOMapper` | DTO -> Domain mapping: correct date parsing, amount conversion, enum mapping, nil handling for optional fields |
| `TransactionEntityMapper` | Domain <-> Entity round-trip: ensure no data loss |
| `TransactionListViewModel` | State transitions: loading -> loaded, loading -> error, pagination trigger, offline fallback, duplicate prevention, hasMorePages detection |
| `FetchTransactionsUseCase` | Calls repository with correct page/size, returns mapped results |
| `TransactionRepository` | Online: fetches remote + saves local. Offline: falls back to local. Pagination: appends correctly |
| `URLSessionHTTPClient` | Correct URL construction, error mapping |
| Pagination edge cases | Detect last page when API returns fewer results than requested; avoid infinite pagination when API returns full pages of duplicates |
| Offline scenarios | Verify fallback to cached data when network fails; verify error state when network fails with no cache |

### Test Doubles
- `MockHTTPClient` — returns predefined responses or errors
- `MockTransactionLocalDataSource` — in-memory store
- `MockTransactionRepository` — for ViewModel tests

### What NOT to test
- SwiftUI views directly (use previews for visual verification)
- SwiftData internals
- Apple framework behavior

### UI Tests
- Only if time permits: one happy-path test that the list loads and displays rows

---

## 12. Trade-offs and Assumptions

### Assumptions
1. **Fixed seed is acceptable.** The API generates random data. Using a fixed seed ensures deterministic pagination (same page always returns same transactions). Without it, pages could overlap or have inconsistent data.
2. **No total page count from API.** We detect the last page by checking if `results.count < pageSize`.
3. **SwiftData over Core Data.** The spec says "Core Data or Realm." SwiftData is Apple's modern replacement for Core Data, targets iOS 17+, and we target iOS 26. It's the right choice.
4. **No authentication.** The API requires none.
5. **Single bank account.** The app doesn't need account switching.
6. **EUR only.** The API always returns EUR. We still store currency for correctness but don't need multi-currency formatting.

### Trade-offs

| Decision | Pro | Con |
|----------|-----|-----|
| SwiftData over Core Data | Modern, less boilerplate, Swift-native | Less community content, fewer edge-case references |
| Fixed seed for pagination | Deterministic, no duplicates | Data never changes across sessions |
| Clean Architecture layers | Testable, clear separation | More files than a simple project needs |
| No Combine, pure async/await | Modern, simpler mental model | Some reactive patterns are more verbose |
| Manual DI over framework | No dependency, easy to understand | Slightly more wiring code |
| Delete-and-reinsert on refresh | Simple, avoids merge conflicts | Brief moment of no cached data during refresh |
| No detail screen | Stays in scope, saves time | Less polished product feel |
| Page size of 30 | Good UX balance | Arbitrary — could be tuned |

### Risk Mitigation
- **API down:** Offline mode ensures the app is still usable with cached data
- **Large datasets:** SwiftData handles thousands of rows efficiently; UI uses lazy loading via `List`
- **Seed changes between sessions:** On fresh fetch we clear old cache, so no stale mixing

---

## 13. Implementation Order (Task Sequence)

This is the recommended order to implement, each step building on the previous:

### Phase 1: Foundation
1. Set up folder structure and groups in Xcode
2. Implement `Core/Networking` — `HTTPClient` protocol, `URLSessionHTTPClient`, `APIEndpoint`, `NetworkError`
3. Implement `Core/Persistence` — `PersistenceController` with SwiftData container

### Phase 2: Data Layer
4. Define all DTOs (`TransactionResponse`, `TransactionDTO`, `AmountDTO`, etc.)
5. Define `TransactionEntity` (SwiftData `@Model`)
6. Implement `TransactionDTOMapper` (DTO -> Domain)
7. Implement `TransactionEntityMapper` (Domain <-> Entity)
8. Implement `TransactionRemoteDataSource` (fetches from API via HTTPClient)
9. Implement `TransactionLocalDataSource` (CRUD on SwiftData)

### Phase 3: Domain Layer
10. Define domain models (`Transaction`, enums)
11. Define `TransactionRepositoryProtocol`
12. Implement `FetchTransactionsUseCase`

### Phase 4: Data Layer (Repository)
13. Implement `TransactionRepository` (coordinates remote + local, offline fallback)

### Phase 5: Presentation
14. Implement `TransactionListViewModel` (state management, pagination logic)
15. Implement `TransactionRowView` (single row UI)
16. Implement `TransactionListView` (list + states + pagination trigger)
17. Implement supporting views (`ErrorView`, `EmptyStateView`, `LoadingView`)
18. Set up `DIContainer` and wire everything in `Qonto_AppApp`

### Phase 6: Polish & Testing
19. Write unit tests for mappers
20. Write unit tests for ViewModel
21. Write unit tests for repository
22. Manual testing: pagination, offline, error states, pull-to-refresh
23. Write technical debrief document

---

*This plan is designed to be convertible into discrete tasks. Each numbered item is a single, focused unit of work.*
