# TASK-009: Implement Remote Data Source

## Goal
Create the remote data source that fetches transaction data from the API using the HTTP client.

## Context
Phase 2: Data Layer. The remote data source uses the Core networking layer to make HTTP requests and decode the response into DTOs.

## Requirements
Create `Data/Remote/TransactionRemoteDataSource.swift`:

### Protocol: `TransactionRemoteDataSourceProtocol`
- `func fetchTransactions(page: Int, results: Int, seed: String) async throws -> TransactionResponse`
- Protocol must be `Sendable`

### Implementation: `TransactionRemoteDataSource`
- Depends on `HTTPClientProtocol` (injected via init)
- Builds URL using `APIEndpoint.transactions(page:results:seed:)`
- Makes the HTTP request via the injected client
- Validates HTTP status code (200 = success, others = error)
- Decodes response JSON into `TransactionResponse` using `JSONDecoder`
- Maps URL errors to `NetworkError` cases:
  - `URLError.notConnectedToInternet` -> `.noConnection`
  - `URLError.timedOut` -> `.timeout`
  - HTTP 5xx -> `.serverError(statusCode:)`
  - Non-200 -> `.invalidResponse`
  - `DecodingError` -> `.decodingFailed`
  - Other -> `.unknown(error)`

## Acceptance Criteria
- Protocol + implementation exist in `Data/Remote/`
- Uses `HTTPClientProtocol` (not URLSession directly) for testability
- Correct URL construction via `APIEndpoint`
- Proper error mapping to `NetworkError`
- JSON decoding with appropriate date strategy
- File compiles successfully

## Constraints
- Do NOT map DTOs to domain models here (that's the repository's job)
- Do NOT persist anything here
- Do NOT handle pagination logic

## Dependencies
- TASK-003 (networking layer — HTTPClient, APIEndpoint, NetworkError)
- TASK-005 (DTOs — TransactionResponse)
