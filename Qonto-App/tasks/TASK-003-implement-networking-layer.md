# TASK-003: Implement Networking Layer

## Goal
Create the HTTP client abstraction and its URLSession implementation, plus API endpoint construction and network error types.

## Context
Phase 1: Foundation. The networking layer lives in Core and provides the infrastructure for the remote data source (TASK-009).

## Requirements
Create the following files in `Core/Networking/`:

### 1. `HTTPClient.swift`
- Protocol `HTTPClientProtocol` with a single method:
  - `func data(from url: URL) async throws -> (Data, URLResponse)`
- Protocol must be `Sendable`

### 2. `URLSessionHTTPClient.swift`
- Concrete implementation of `HTTPClientProtocol`
- Uses `URLSession.shared` (or an injected session)
- Simply forwards to `URLSession.data(from:)`

### 3. `APIEndpoint.swift`
- Struct or enum that builds the transactions API URL
- Base URL: `https://us-central1-qonto-staging.cloudfunctions.net`
- Path: `/transactions`
- Query parameters: `results` (Int), `page` (Int), `seed` (String)
- Static method: `static func transactions(page: Int, results: Int, seed: String) -> URL`

### 4. `NetworkError.swift`
- Enum `NetworkError: Error, Sendable` with cases:
  - `.noConnection`
  - `.timeout`
  - `.serverError(statusCode: Int)`
  - `.invalidResponse`
  - `.decodingFailed`
  - `.unknown(Error)`

## Acceptance Criteria
- All 4 files exist in `Core/Networking/`
- `HTTPClientProtocol` is a testable protocol (can be mocked)
- `APIEndpoint.transactions(page:results:seed:)` produces the correct URL with query parameters
- `NetworkError` covers all error cases from the plan
- Project builds successfully

## Constraints
- Do NOT add business logic
- Do NOT import Domain layer types
- Do NOT make network calls at this stage (just define the types)

## Dependencies
- TASK-001 (folder structure)
