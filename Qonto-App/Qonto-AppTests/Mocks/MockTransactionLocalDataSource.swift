import Foundation
@testable import Qonto_App


final class MockTransactionLocalDataSource: TransactionLocalDataSourceProtocol {
    nonisolated(unsafe) var storedEntities: [TransactionEntity] = []
    nonisolated(unsafe) var fetchAllCallCount = 0
    nonisolated(unsafe) var saveCallCount = 0
    nonisolated(unsafe) var deleteAllCallCount = 0
    nonisolated(unsafe) var hasDataCallCount = 0
    nonisolated(unsafe) var lastSavedEntities: [TransactionEntity] = []
    nonisolated(unsafe) var lastSavedPage: Int?
    nonisolated(unsafe) var shouldThrowOnSave = false
    nonisolated(unsafe) var shouldThrowOnFetch = false

    func fetchAll() async throws -> [TransactionEntity] {
        fetchAllCallCount += 1
        if shouldThrowOnFetch {
            throw PersistenceError.saveFailed(NSError(domain: "test", code: 1))
        }
        return storedEntities
    }

    func save(entities: [TransactionEntity], page: Int) async throws {
        saveCallCount += 1
        lastSavedEntities = entities
        lastSavedPage = page
        if shouldThrowOnSave {
            throw PersistenceError.saveFailed(NSError(domain: "test", code: 1))
        }
        storedEntities.append(contentsOf: entities)
    }

    func deleteAll() async throws {
        deleteAllCallCount += 1
        storedEntities = []
    }

    func hasData() async -> Bool {
        hasDataCallCount += 1
        return !storedEntities.isEmpty
    }
}
