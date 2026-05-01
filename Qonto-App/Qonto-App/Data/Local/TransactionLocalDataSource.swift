import Foundation

protocol TransactionLocalDataSourceProtocol: Sendable {
    func fetchAll() async throws -> [TransactionEntity]
    func save(entities: [TransactionEntity], page: Int) async throws
    func deleteAll() async throws
    func hasData() async -> Bool
}

final class TransactionLocalDataSource: TransactionLocalDataSourceProtocol {
    private let persistenceService: any PersistenceServicing
    private let maxCachedPages = 5

    init(persistenceService: any PersistenceServicing) {
        self.persistenceService = persistenceService
    }

    func fetchAll() async throws -> [TransactionEntity] {
        try await persistenceService.fetch(
            TransactionEntity.self,
            predicate: nil,
            sortBy: [SortDescriptor(\.emittedAt, order: .reverse)]
        )
    }

    func save(entities: [TransactionEntity], page: Int) async throws {
        for entity in entities {
            let entityID = entity.id
            let existing = try await persistenceService.fetch(
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
                try await persistenceService.insert(entity)
            }
        }

        try await deleteOldestPages(keeping: maxCachedPages)
    }

    func deleteAll() async throws {
        try await persistenceService.deleteAll(TransactionEntity.self)
    }

    private func deleteOldestPages(keeping maxPages: Int) async throws {
        let allEntities = try await persistenceService.fetchAll(TransactionEntity.self)
        let distinctPages = Set(allEntities.map(\.page)).sorted()

        guard distinctPages.count > maxPages else { return }

        let pagesToDelete = Set(distinctPages.prefix(distinctPages.count - maxPages))

        for entity in allEntities where pagesToDelete.contains(entity.page) {
            try await persistenceService.delete(entity)
        }
    }

    func hasData() async -> Bool {
        let count = await (try? persistenceService.count(TransactionEntity.self)) ?? 0
        return count > 0
    }
}
