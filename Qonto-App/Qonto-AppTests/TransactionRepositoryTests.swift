import Foundation
import Testing
@testable import Qonto_App

// MARK: - Test Helpers

private func makeTransactionDTO(id: String = "txn-1") -> TransactionDTO {
    TransactionDTO(
        id: id,
        amount: AmountDTO(value: "100.00", currency: "EUR"),
        counterpartyName: "Test",
        emittedAt: "2025-03-15T10:30:00.000Z",
        settledAt: nil,
        side: "DEBIT",
        status: "COMPLETED",
        operationMethod: "CARD",
        operationType: "CARD",
        description: "Test payment",
        activityTag: "OTHER_EXPENSE",
        note: nil,
        initiator: nil,
        bankAccount: BankAccountDTO(id: "acc-1", name: "Main")
    )
}

private func makeResponse(dtos: [TransactionDTO]) -> TransactionResponse {
    TransactionResponse(
        results: dtos,
        info: InfoDTO(seed: "qonto", results: dtos.count, page: 1, version: "1.0")
    )
}

private func makeEntity(id: String = "txn-1", page: Int = 1) -> TransactionEntity {
    TransactionEntity(
        id: id,
        counterpartyName: "Cached",
        amount: 50,
        currency: "EUR",
        emittedAt: Date(timeIntervalSince1970: 1710500000),
        settledAt: nil,
        side: "DEBIT",
        status: "COMPLETED",
        operationMethod: "CARD",
        operationType: "CARD",
        descriptionText: "Cached payment",
        activityTag: "OTHER_EXPENSE",
        note: nil,
        initiatorName: nil,
        bankAccountName: "Main",
        page: page
    )
}

// MARK: - Tests

@MainActor
struct TransactionRepositoryTests {

    private func makeSUT() -> (repository: TransactionRepository, remote: MockTransactionRemoteDataSource, local: MockTransactionLocalDataSource) {
        let remote = MockTransactionRemoteDataSource()
        let local = MockTransactionLocalDataSource()
        let repo = TransactionRepository(remoteDataSource: remote, localDataSource: local)
        return (repo, remote, local)
    }

    // MARK: - Network-First (Online)

    @Test func onlineSuccess_returnsFreshMappedDomainModels() async throws {
        let (repo, remote, _) = makeSUT()
        let dto = makeTransactionDTO(id: "txn-1")
        remote.responseToReturn = makeResponse(dtos: [dto])

        let result = try await repo.fetchTransactions(page: 1, results: 30)

        #expect(result.isCached == false)
        #expect(result.transactions.count == 1)
        #expect(result.transactions[0].id == "txn-1")
    }

    @Test func onlinePage1_callsDeleteAllBeforeSaving() async throws {
        let (repo, remote, local) = makeSUT()
        remote.responseToReturn = makeResponse(dtos: [makeTransactionDTO()])

        _ = try await repo.fetchTransactions(page: 1, results: 30)

        #expect(local.deleteAllCallCount == 1)
        #expect(local.saveCallCount == 1)
    }

    @Test func onlinePage2_doesNotCallDeleteAll() async throws {
        let (repo, remote, local) = makeSUT()
        remote.responseToReturn = makeResponse(dtos: [makeTransactionDTO()])

        _ = try await repo.fetchTransactions(page: 2, results: 30)

        #expect(local.deleteAllCallCount == 0)
        #expect(local.saveCallCount == 1)
    }

    @Test func onlineSuccess_savesEntitiesToLocal() async throws {
        let (repo, remote, local) = makeSUT()
        let dto1 = makeTransactionDTO(id: "txn-1")
        let dto2 = makeTransactionDTO(id: "txn-2")
        remote.responseToReturn = makeResponse(dtos: [dto1, dto2])

        _ = try await repo.fetchTransactions(page: 1, results: 30)

        #expect(local.lastSavedEntities.count == 2)
        #expect(local.lastSavedPage == 1)
    }

    @Test func onlineSuccess_savesCorrectPageNumber() async throws {
        let (repo, remote, local) = makeSUT()
        remote.responseToReturn = makeResponse(dtos: [makeTransactionDTO()])

        _ = try await repo.fetchTransactions(page: 3, results: 30)

        #expect(local.lastSavedPage == 3)
    }

    @Test func onlineSuccess_cacheSaveFailure_stillReturnsFreshData() async throws {
        let (repo, remote, local) = makeSUT()
        remote.responseToReturn = makeResponse(dtos: [makeTransactionDTO(id: "txn-1")])
        local.shouldThrowOnSave = true

        let result = try await repo.fetchTransactions(page: 1, results: 30)

        #expect(result.isCached == false)
        #expect(result.transactions.count == 1)
    }

    // MARK: - Offline Fallback

    @Test func offlinePage1_withCache_returnsCachedData() async throws {
        let (repo, remote, local) = makeSUT()
        remote.errorToThrow = .requestFailed(NSError(domain: "test", code: -1009))
        local.storedEntities = [makeEntity(id: "cached-1"), makeEntity(id: "cached-2")]

        let result = try await repo.fetchTransactions(page: 1, results: 30)

        #expect(result.isCached == true)
        #expect(result.transactions.count == 2)
        #expect(result.transactions[0].id == "cached-1")
    }

    @Test func offlinePage1_noCache_throwsError() async {
        let (repo, remote, _) = makeSUT()
        remote.errorToThrow = .requestFailed(NSError(domain: "test", code: -1009))

        do {
            _ = try await repo.fetchTransactions(page: 1, results: 30)
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected — original error is rethrown
        }
    }

    @Test func offlinePage2_withCache_throwsError() async {
        let (repo, remote, local) = makeSUT()
        remote.errorToThrow = .requestFailed(NSError(domain: "test", code: -1009))
        local.storedEntities = [makeEntity(id: "cached-1")]

        do {
            _ = try await repo.fetchTransactions(page: 2, results: 30)
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected — no fallback for page > 1
        }
    }

    @Test func offlinePage1_fetchAllFails_throwsError() async {
        let (repo, remote, local) = makeSUT()
        remote.errorToThrow = .requestFailed(NSError(domain: "test", code: -1009))
        local.storedEntities = [makeEntity()] // hasData returns true
        local.shouldThrowOnFetch = true

        do {
            _ = try await repo.fetchTransactions(page: 1, results: 30)
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected — fetchAll failed so no cached data
        }
    }

    // MARK: - Mapping Verification

    @Test func dtoMapping_returnsDomainModelsFromDTOs() async throws {
        let (repo, remote, _) = makeSUT()
        let dto = makeTransactionDTO(id: "mapped-1")
        remote.responseToReturn = makeResponse(dtos: [dto])

        let result = try await repo.fetchTransactions(page: 1, results: 30)

        let transaction = result.transactions[0]
        #expect(transaction.id == "mapped-1")
        #expect(transaction.amount == Decimal(string: "100.00"))
        #expect(transaction.currency == "EUR")
        #expect(transaction.side == .debit)
        #expect(transaction.operationMethod == .card)
    }

    @Test func entityMapping_returnsDomainModelsFromCache() async throws {
        let (repo, remote, local) = makeSUT()
        remote.errorToThrow = .requestFailed(NSError(domain: "test", code: -1009))
        local.storedEntities = [makeEntity(id: "entity-1")]

        let result = try await repo.fetchTransactions(page: 1, results: 30)

        let transaction = result.transactions[0]
        #expect(transaction.id == "entity-1")
        #expect(transaction.counterpartyName == "Cached")
        #expect(transaction.amount == 50)
    }
}
