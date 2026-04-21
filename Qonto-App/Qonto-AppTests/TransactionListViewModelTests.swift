import Foundation
import Testing
@testable import Qonto_App

// MARK: - Mock Use Case

@MainActor
final class MockFetchTransactionsUseCase: FetchTransactionsUseCaseProtocol {
    nonisolated func execute(page: Int, results: Int) async throws -> FetchResult {
        await MainActor.run {
            callCount += 1
            lastPage = page
            lastResults = results
            return Void()
        }
        if let error = await errorToThrow {
            throw error
        }
        return await resultToReturn
    }

    var resultToReturn: FetchResult = .fresh([])
    var errorToThrow: (any Error)?
    var callCount = 0
    var lastPage: Int?
    var lastResults: Int?
}

// MARK: - Test Helpers

private func makeTransaction(id: String) -> Transaction {
    Transaction(
        id: id,
        counterpartyName: "Test",
        amount: 100,
        currency: "EUR",
        emittedAt: .now,
        settledAt: nil,
        side: .debit,
        status: .completed,
        operationMethod: .card,
        operationType: .card,
        description: "Test",
        activityTag: .otherExpense,
        note: nil,
        initiatorName: nil,
        bankAccountName: "Main"
    )
}

private func makeTransactions(count: Int, startingAt offset: Int = 0) -> [Transaction] {
    (0..<count).map { makeTransaction(id: "txn-\($0 + offset)") }
}

// MARK: - Tests

@MainActor
struct TransactionListViewModelTests {

    // MARK: - State Transitions

    @Test func initialState_isLoading() {
        let mock = MockFetchTransactionsUseCase()
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)

        #expect(vm.viewState == .loading)
        #expect(vm.transactions.isEmpty)
    }

    @Test func loadInitial_successWithData_setsLoaded() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 10))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)

        await vm.loadInitialTransactions()

        #expect(vm.viewState == .loaded)
        #expect(vm.transactions.count == 10)
    }

    @Test func loadInitial_successWithEmptyData_setsLoaded() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh([])
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)

        await vm.loadInitialTransactions()

        #expect(vm.viewState == .loaded)
        #expect(vm.transactions.isEmpty)
    }

    @Test func loadInitial_failure_setsError() async {
        let mock = MockFetchTransactionsUseCase()
        mock.errorToThrow = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)

        await vm.loadInitialTransactions()

        if case .error(let message) = vm.viewState {
            #expect(message == "Network error")
        } else {
            Issue.record("Expected .error state, got \(vm.viewState)")
        }
    }

    @Test func loadInitial_cachedWithData_setsLoaded() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .cached(makeTransactions(count: 5))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)

        await vm.loadInitialTransactions()

        #expect(vm.viewState == .loaded)
        #expect(vm.transactions.count == 5)
        #expect(vm.hasMorePages == false)
    }

    @Test func loadInitial_cachedEmpty_setsError() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .cached([])
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)

        await vm.loadInitialTransactions()

        if case .error = vm.viewState {
            // Expected
        } else {
            Issue.record("Expected .error state, got \(vm.viewState)")
        }
    }

    // MARK: - Pagination

    @Test func loadMore_appendsResults() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        mock.resultToReturn = .fresh(makeTransactions(count: 10, startingAt: 30))
        await vm.loadMoreTransactions()

        #expect(vm.transactions.count == 40)
        #expect(mock.lastPage == 2)
    }

    @Test func loadMore_doesNotFetch_whenHasNoMorePages() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 10)) // < 30 = no more pages
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        #expect(vm.hasMorePages == false)

        let callCountBefore = mock.callCount
        await vm.loadMoreTransactions()

        #expect(mock.callCount == callCountBefore)
    }

    @Test func loadMore_lessThanPageSize_setsHasMorePagesFalse() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        #expect(vm.hasMorePages == true)

        mock.resultToReturn = .fresh(makeTransactions(count: 15, startingAt: 30))
        await vm.loadMoreTransactions()

        #expect(vm.hasMorePages == false)
    }

    @Test func loadMore_allDuplicates_setsHasMorePagesFalse() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        // Return same transactions again
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        await vm.loadMoreTransactions()

        #expect(vm.hasMorePages == false)
        #expect(vm.transactions.count == 30)
    }

    @Test func loadMore_deduplicates() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        // Mix of new and duplicate
        let mixed = makeTransactions(count: 15, startingAt: 25) // 25-39, overlaps 25-29
        mock.resultToReturn = .fresh(mixed)
        await vm.loadMoreTransactions()

        #expect(vm.transactions.count == 40) // 30 original + 10 new (30-39)
    }

    @Test func loadMore_failure_silentlyFails() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        mock.errorToThrow = NSError(domain: "test", code: 1)
        await vm.loadMoreTransactions()

        #expect(vm.viewState == .loaded)
        #expect(vm.transactions.count == 30)
    }

    // MARK: - Refresh

    @Test func refresh_reloadsFromPage1() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        mock.resultToReturn = .fresh(makeTransactions(count: 20, startingAt: 100))
        await vm.refresh()

        #expect(vm.transactions.count == 20)
        #expect(mock.lastPage == 1)
    }

    @Test func refresh_cachedResult_keepsCurrentState() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        let originalTransactions = vm.transactions
        mock.resultToReturn = .cached(makeTransactions(count: 5))
        await vm.refresh()

        // Should keep current data, not replace with cached
        #expect(vm.transactions == originalTransactions)
        #expect(vm.viewState == .loaded)
    }

    @Test func refresh_failureWithData_silentlyFails() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        mock.errorToThrow = NSError(domain: "test", code: 1)
        await vm.refresh()

        #expect(vm.viewState == .loaded)
        #expect(vm.transactions.count == 30)
    }

    @Test func refresh_failureWithNoData_setsError() async {
        let mock = MockFetchTransactionsUseCase()
        mock.errorToThrow = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)

        await vm.refresh()

        if case .error = vm.viewState {
            // Expected
        } else {
            Issue.record("Expected .error state, got \(vm.viewState)")
        }
    }

    // MARK: - onTransactionAppear

    @Test func onTransactionAppear_nearEnd_triggersLoadMore() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        let callCountBefore = mock.callCount
        let nearEndTransaction = vm.transactions[28] // 2nd from end
        mock.resultToReturn = .fresh(makeTransactions(count: 30, startingAt: 30))
        await vm.onTransactionAppear(transaction: nearEndTransaction)

        #expect(mock.callCount == callCountBefore + 1)
    }

    @Test func onTransactionAppear_notNearEnd_doesNotTriggerLoadMore() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        let callCountBefore = mock.callCount
        let earlyTransaction = vm.transactions[5]
        await vm.onTransactionAppear(transaction: earlyTransaction)

        #expect(mock.callCount == callCountBefore)
    }

    // MARK: - hasMorePages

    @Test func fullPage_setsHasMorePagesTrue() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 30))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        #expect(vm.hasMorePages == true)
    }

    @Test func partialPage_setsHasMorePagesFalse() async {
        let mock = MockFetchTransactionsUseCase()
        mock.resultToReturn = .fresh(makeTransactions(count: 15))
        let vm = TransactionListViewModel(fetchTransactionsUseCase: mock)
        await vm.loadInitialTransactions()

        #expect(vm.hasMorePages == false)
    }
}
