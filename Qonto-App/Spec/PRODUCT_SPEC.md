# PRODUCT_SPEC.md

## Product Overview

Build an iOS application for the Qonto skills test that fetches transactions from the provided Transactions API and displays them in a scrollable list.

Primary API endpoint:
- `https://us-central1-qonto-staging.cloudfunctions.net/transactions`

API documentation:
- `Api-Doc.pdf` (must be read before planning or implementation)

The app must reflect Qonto's product expectations:
- complex actions should feel simple
- the experience should be fast
- the behavior should be transparent to the user

The project also includes a technical debrief Markdown document explaining the implementation choices, architecture, development strategy, and engineering practices.

## Core Features

### 1. Transactions List
The app must:
- fetch transactions from the provided API
- display a list of transactions
- show at least:
  - `counterpartyName` and `amount` on the first line
  - `settledAt` and `status` on the second line

Important:
- The above represents the minimum UI requirement
- The implementation is expected to analyze the data model and propose an improved, user-friendly UI if relevant
- Any enhancement should remain simple, clear, and aligned with Qonto's product philosophy

### 2. Pagination
The app must:
- fetch multiple pages from the API
- load following pages when the user scrolls the list
- avoid duplicate items
- avoid unnecessary repeated page loads

### 3. Offline Access
The app must:
- persist previously loaded transactions locally
- allow the user to access already loaded transactions while offline
- use a classic local database solution such as Core Data or Realm

### 4. Error Handling and UX States
The app must:
- handle loading, empty, error, and offline states in the UI
- show proper user-facing error messages when something goes wrong
- provide clear and user-friendly feedback for recoverable failures
- handle edge cases with sensible UI and UX flows

### 5. Technical Debrief Document
The project must include a Markdown document answering:
- the personal context during the test
- architecture and main components
- how components interact
- where good practices were applied
- development strategy
- commit strategy
- future-proofing and scalability considerations

## UI Expectations

The UI should be:
- simple
- clear
- user friendly

The minimum required fields must be displayed, but the final UI design should be thoughtfully proposed based on the data model and usability considerations.

## Main Behavior Rules

- The list is the main screen of the application.
- Transactions should appear progressively as pages are loaded.
- Scrolling near the end of the list should trigger loading the next page.
- If network access is unavailable, already cached transactions should still be visible.
- If an error occurs, the UI should communicate it clearly with an appropriate message.
- The app should handle edge cases cleanly, including first load failure, pagination failure, no data, duplicate prevention, and offline behavior after prior successful loads.
- The implementation should favor readability and explicit architectural decisions over unnecessary complexity.

## Data Source Assumptions

- The remote source for transactions is:
  - `https://us-central1-qonto-staging.cloudfunctions.net/transactions`
- The API contract must be fully understood by reading:
  - `Api-Doc.pdf`
- The Transactions API is the remote source of truth for newly fetched data.
- The local database stores transactions already fetched by the app.
- The app may read from local storage to provide offline access.
- Pagination metadata is expected to be provided by the API contract.
- The exact transaction model should be derived from the API response and documentation.

## Scope Boundaries

### In Scope
- transaction list screen
- paginated fetching
- local persistence for offline access
- clear UI states and user-facing error handling
- simple and user-friendly UI
- clean and explainable architecture
- Markdown debrief document

### Out of Scope
- authentication unless explicitly required by the API
- transaction details screen unless needed for clarity
- editing or creating transactions
- advanced filtering or search
- animations or heavy UI polish not needed for the test
- over-engineering beyond what is needed to demonstrate strong engineering judgment

## Success Criteria

The submission is successful if:
- the app fetches and displays paginated transactions correctly
- users can continue seeing previously loaded transactions offline
- the UI remains simple, clear, and user friendly
- errors and edge cases are handled with proper UI feedback
- the architecture is easy to explain during the debrief
- the accompanying Markdown document clearly justifies technical choices