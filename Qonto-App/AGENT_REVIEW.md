# Agent Review Log

This file tracks corrections and mistakes caught during plan/code reviews. Each entry documents what went wrong, where, and the fix applied.

---

## Session: 2026-04-20

### 1. Domain enums incorrectly marked as Codable
- **Section:** 4.2 Domain Models — Enums
- **What was wrong:** Domain enums were declared as `Codable`. Domain models are never encoded/decoded directly — DTOs handle JSON decoding and Entities store raw strings. `Codable` on domain enums is unnecessary and misleading.
- **Correction:** Changed to `Sendable`, `Hashable` only.
- **Lesson:** Domain models should only conform to protocols they actually need. Codable belongs on the Data layer (DTOs/Entities), not on Domain types.

### 2. Mapper placement violated Clean Architecture dependency rule
- **Section:** 4.4 Mapping Strategy
- **What was wrong:** The plan described mappers as initializers on domain types (e.g., `Transaction(from dto:)`), which would make the Domain layer import and depend on Data layer DTOs. This violates the inward dependency rule of Clean Architecture.
- **Correction:** Mappers are standalone structs in `Data/Mappers/` (e.g., `TransactionDTOMapper.mapToDomain(dto:)`). The Repository calls mappers and returns clean domain models. Domain never knows about DTOs or Entities.
- **Lesson:** In Clean Architecture, the Domain layer must never import anything from the Data layer. All mapping responsibility belongs to the Data layer, typically inside the Repository or dedicated mapper classes.

### 3. Unnecessary TransactionPage model added complexity
- **Section:** 5. Folder Structure / 13. Implementation Order
- **What was wrong:** A `TransactionPage` domain model was listed in the folder structure and implementation tasks. It was unnecessary — the ViewModel can track page state (`currentPage`, `hasMorePages`) directly since pagination is a presentation concern, not a domain concept.
- **Correction:** Removed `TransactionPage.swift` from the folder structure and from implementation task 10.
- **Lesson:** Don't introduce domain models for concepts that are purely presentation-layer state. Keep the domain layer focused on business entities.

### 4. Offline banner was vaguely described
- **Section:** 7. Offline Strategy — Sync Behavior / 8. Error Handling — UI Error States
- **What was wrong:** The plan said "non-blocking banner" and "top banner" without specifying what the component actually is or what it says.
- **Correction:** Clarified as a small non-dismissible informational strip below the nav bar with `wifi.slash` SF Symbol and text: "You're viewing cached data. Pull to refresh when back online."
- **Lesson:** UI descriptions in a plan should be concrete enough that a developer can implement them without guessing. Specify the component type, content, and placement.

### 5. Empty state description was vague
- **Section:** 8. Error Handling — UI Error States
- **What was wrong:** Empty state was described as "Full-screen empty state illustration" which doesn't clearly communicate what the user sees.
- **Correction:** Changed to explicit "Full-screen empty state with a `tray` SF Symbol and explicit message: 'No transactions yet'".
- **Lesson:** Always describe empty/error states with their actual user-facing content, not abstract descriptions like "illustration."

---

## Session: 2026-04-20 (Round 2)

### 6. Missing local storage cap — unbounded persistence
- **Section:** 7. Offline Strategy — Persistence Rules
- **What was wrong:** The plan had no limit on how many transactions could be stored locally. With up to 10,000 pages × 30 results, this could grow to 300,000 rows.
- **Correction:** Added `maxCachedPages = 10` (~300 transactions). Oldest pages are evicted when the cap is exceeded. Pull-to-refresh resets naturally.
- **Lesson:** Always define upper bounds for local storage. Unbounded caching is a silent scalability risk.

### 7. Missing SwiftData threading decision
- **Section:** 7. Offline Strategy (new subsection)
- **What was wrong:** The plan never specified which thread SwiftData operations run on. This is a critical concurrency decision.
- **Correction:** All operations use `mainContext` on `@MainActor`. With 30 items per page and a 300-item cap, background threading adds complexity without measurable benefit.
- **Lesson:** Always document threading decisions for persistence. Choose the simplest correct approach — don't add `@ModelActor` overhead for trivial workloads.

### 8. ViewModel responsibility wording was imprecise
- **Section:** 3.1 Presentation Layer
- **What was wrong:** "ViewModels own business logic orchestration via use cases" could be misread as ViewModels owning business logic itself.
- **Correction:** Changed to "ViewModels orchestrate use cases and manage UI state, but do not contain core business rules (which belong to the domain layer)."
- **Lesson:** Be precise about layer boundaries in architecture descriptions. Ambiguous wording creates confusion about where logic lives.

### 9. Transaction list sorting was not specified
- **Section:** 9. UI Approach — UI Enhancements
- **What was wrong:** Section headers grouped by date but did not specify sort order. Most recent first is the standard UX for transaction lists.
- **Correction:** Added "sort in descending order (most recent first)" to the date grouping description.
- **Lesson:** Always specify sort order explicitly. "Grouped by date" is ambiguous without a direction.

### 10. Pagination end detection had a single failure mode
- **Section:** 6. Pagination Strategy — End detection / Flow
- **What was wrong:** Only checked `results.count < pageSize`. If the API returns full pages of duplicate IDs, pagination would loop infinitely.
- **Correction:** Added dual detection: (1) fewer results than requested, OR (2) all returned IDs already exist (duplicate-only page).
- **Lesson:** Defensive pagination needs multiple termination conditions. Don't rely on a single signal from an API you don't control.

### 11. Unit tests missing critical edge cases
- **Section:** 11. Testing Strategy — Unit Tests
- **What was wrong:** Test table didn't explicitly cover pagination edge cases (last page detection, infinite pagination prevention) or offline fallback scenarios.
- **Correction:** Added two test entries: pagination edge cases and offline scenarios.
- **Lesson:** Test strategy should explicitly call out edge cases and failure paths, not just happy paths.

---

## Session: 2026-04-20 (Round 3)

### 12. Offline sync wording implied a visible delete-then-insert gap
- **Section:** 7. Offline Strategy — Sync Behavior
- **What was wrong:** "Clear old cached data, save new data to SwiftData, display it" implied a two-step operation where the user might briefly see an empty state between delete and insert.
- **Correction:** Reworded to "Replace existing cached data with fresh data, then display it." Also changed failure path to "Keep existing cached transactions" for clarity.
- **Lesson:** Wording matters in plans — describe the user-visible outcome, not the internal steps that could imply intermediate states.

### 15. Networking layer was too basic — lacked proper request modeling and validation
- **Task:** TASK-003 — Implement Networking Layer
- **What was wrong:** Initial implementation used a bare `HTTPClientProtocol` with `func data(from url: URL)` that simply forwarded to URLSession. It had no HTTP method support, no headers, no status code validation, no response decoding, and no typed error handling. The error enum had vague cases like `.noConnection` and `.timeout` that duplicated URLSession's own error handling.
- **Correction:** Rewrote to a proper `NetworkServicing` protocol with a generic `send<Response: Decodable>(_ request:)` method. Added `HTTPMethod` enum, `NetworkRequest` struct for request modeling, status code validation (2xx range), JSON decoding with typed errors, and `LocalizedError` conformance with descriptive messages. Error cases now map to actual failure points: `invalidURL`, `invalidResponse`, `requestFailed`, `unacceptableStatusCode`, `decodingFailed`.
- **Lesson:** A networking layer should handle the full request lifecycle — building the request, validating the response, and decoding the result. Don't just wrap URLSession; add the validation and error mapping that every caller would otherwise duplicate.

### 16. Persistence layer abstracted behind technology-agnostic protocol
- **Task:** TASK-004 — Implement Persistence Controller
- **What was wrong:** The original plan had `PersistenceController` directly creating and exposing a `ModelContainer`, coupling the Data layer to SwiftData. The local data source would have depended on SwiftData types directly, making it impossible to swap storage technologies without rewriting the Data layer.
- **Correction:** Introduced a `Persistable` marker protocol and a `PersistenceServicing` protocol that defines generic CRUD operations (`fetchAll`, `count`, `insert`, `delete`, `deleteAll`, `save`) without importing SwiftData. `SwiftDataPersistenceService` implements the protocol using runtime casts from `Persistable` to `PersistentModel`. The protocol deliberately avoids `Predicate`/`SortDescriptor` in its interface since `FetchDescriptor` requires compile-time `PersistentModel` conformance — domain-specific querying (sorting, filtering) is handled by the local data source layer on top.
- **Lesson:** Infrastructure abstractions should not leak framework types into their public interface. A marker protocol (`Persistable`) provides the boundary between storage-agnostic code and storage-specific implementations. Accept the trade-off of runtime type checks at the implementation boundary to keep the protocol clean.

### 17. Force unwrap removed from SwiftDataPersistenceService, type-casting extracted
- **Task:** TASK-004 — Implement Persistence Controller
- **What was wrong:** `fetchAll` used `as! [T]` to cast fetch results — a force unwrap that would crash at runtime if the types didn't match. Additionally, the `guard let ... as? any PersistentModel` pattern was duplicated across every method (`insert`, `delete`, `deleteAll`, `count`, `fetchAll`).
- **Correction:** Replaced `as! [T]` with `guard let ... as? [T] else { throw PersistenceError.incompatibleModelType }`. Extracted the repeated guard-cast pattern into two reusable helpers: `toPersistentModelType(_:)` for type casts and `toPersistentModel(_:)` for instance casts. Each public method is now a single-line cast + operation.
- **Lesson:** Never use force unwraps at abstraction boundaries where type mismatches are possible. Extract repeated guard-throw patterns into throwing helpers to keep code DRY and make the error path consistent.

### 13. Proposed Data Access Strategy section was redundant
- **Section:** Proposed new section 7.1
- **What was wrong:** User proposed a "Data Access Strategy" section describing network-first with fallback. This was already fully covered in the existing Offline Strategy section (Source of Truth + Sync Behavior).
- **Correction:** Instead of a new section, added a one-line summary to Source of Truth: "The app follows a network-first strategy: always attempt the API first, fall back to local cache on failure."
- **Lesson:** Before adding a new section, check if the content already exists elsewhere. Prefer consolidation over duplication — DRY applies to documentation too.

### 14. Upsert mechanism was not explained in Persistence Rules
- **Section:** 7. Offline Strategy — Persistence Rules
- **What was wrong:** The plan said "insert/upsert new entities" without explaining how upsert works. The mechanism (check by `id`, update if exists, insert if not) was left implicit.
- **Correction:** Expanded the bullet to: "upsert new entities: check by `id` — if a transaction with the same `id` already exists, update it; if not, insert it."
- **Lesson:** Implementation-relevant details like upsert strategy should be explicit in the plan. "Upsert" alone is ambiguous — specify the key and behavior.
