# TASK-024: Add OSLog Logger for Non-Fatal Events

## Goal
Replace `print` statements with Apple's `os.Logger` for structured, filterable logging of non-fatal events.

## Context
Optional polish task. Only execute if time permits after all core tasks are complete.

## Requirements

### Add logging to:
- **TransactionRepository** — cache write failures (non-fatal catch block)
- **TransactionRepository** — offline fallback activation (when returning `.cached`)
- **TransactionDTOMapper** — optionally log dropped invalid DTOs in `mapToDomain(dtos:)`
- **TransactionEntityMapper** — optionally log dropped invalid entities in `mapToDomain(entities:)`

### Implementation:
- Use `import OSLog` and `Logger(subsystem:category:)`
- Subsystem: `Bundle.main.bundleIdentifier ?? "com.qonto.app"`
- Categories: `"Repository"`, `"Mapper"` (one Logger per category)
- Log levels: `.error` for cache failures, `.info` for fallback activation, `.debug` for dropped records

## Acceptance Criteria
- No `print` statements remain in production code
- Logs are filterable in Console.app by subsystem/category
- Zero runtime cost when not observed (Logger guarantees this)
- File compiles successfully

## Constraints
- Do NOT add logging for happy-path operations
- Do NOT create a logging abstraction/wrapper — use `Logger` directly

## Dependencies
- TASK-013 (repository)
- TASK-007 (DTO mapper)
- TASK-008 (entity mapper)
