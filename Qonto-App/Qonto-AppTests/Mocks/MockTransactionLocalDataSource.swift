import Foundation
@testable import Qonto_App

@MainActor
final class MockTransactionLocalDataSource: TransactionLocalDataSourceProtocol {
    var storedEntities: [TransactionEntity] = []
    var fetchAllCallCount = 0
    var saveCallCount = 0
    var deleteAllCallCount = 0
    var hasDataCallCount = 0
    var lastSavedEntities: [TransactionEntity] = []
    var lastSavedPage: Int?
    var shouldThrowOnSave = false
    var shouldThrowOnFetch = false

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
