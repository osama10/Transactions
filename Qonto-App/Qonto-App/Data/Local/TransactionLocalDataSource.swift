import Foundation

/// Protocol defining the contract for local persistence operations on transactions.
/// All operations are `@MainActor`-isolated since they use SwiftData's `mainContext`.
@MainActor
protocol TransactionLocalDataSourceProtocol {
    func fetchAll() throws -> [TransactionEntity]
    func save(entities: [TransactionEntity], page: Int) throws
    func deleteAll() throws
    func hasData() -> Bool
}

/// Concrete implementation that manages transaction persistence via the generic persistence layer.
@MainActor
final class TransactionLocalDataSource: TransactionLocalDataSourceProtocol {
    private let persistenceService: any PersistenceServicing
    private let maxCachedPages = 5

    init(persistenceService: any PersistenceServicing) {
        self.persistenceService = persistenceService
    }

    func fetchAll() throws -> [TransactionEntity] {
        try persistenceService.fetch(
            TransactionEntity.self,
            predicate: nil,
            sortBy: [SortDescriptor(\.emittedAt, order: .reverse)]
        )
    }

    func save(entities: [TransactionEntity], page: Int) throws {
        for entity in entities {
            let entityID = entity.id
            let existing = try persistenceService.fetch(
                TransactionEntity.self,
                predicate: #Predicate { $0.id == entityID },
                sortBy: []
            ).first

            if let existing {
                existing.counterpartyName = entity.counterpartyName
                existing.amount = entity.amount
                existing.currency = entity.currency
                existing.emittedAt = entity.emittedAt
                existing.settledAt = entity.settledAt
                existing.side = entity.side
                existing.status = entity.status
                existing.operationMethod = entity.operationMethod
                existing.operationType = entity.operationType
                existing.descriptionText = entity.descriptionText
                existing.activityTag = entity.activityTag
                existing.note = entity.note
                existing.initiatorName = entity.initiatorName
                existing.bankAccountName = entity.bankAccountName
                existing.page = entity.page
            } else {
                try persistenceService.insert(entity)
            }
        }

        try deleteOldestPages(keeping: maxCachedPages)
    }

    func deleteAll() throws {
        try persistenceService.deleteAll(TransactionEntity.self)
    }

    private func deleteOldestPages(keeping maxPages: Int) throws {
        let allEntities = try persistenceService.fetchAll(TransactionEntity.self)
        let distinctPages = Set(allEntities.map(\.page)).sorted()

        guard distinctPages.count > maxPages else { return }

        let pagesToDelete = Set(distinctPages.prefix(distinctPages.count - maxPages))

        for entity in allEntities where pagesToDelete.contains(entity.page) {
            try persistenceService.delete(entity)
        }
    }

    func hasData() -> Bool {
        let count = (try? persistenceService.count(TransactionEntity.self)) ?? 0
        return count > 0
    }
}
