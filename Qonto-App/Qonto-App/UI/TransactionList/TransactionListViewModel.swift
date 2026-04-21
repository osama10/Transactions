import Foundation

@MainActor
@Observable
final class TransactionListViewModel {

    // MARK: - ViewState

    enum ViewState: Equatable {
        case loading
        case loaded
        case error(String)
    }

    // MARK: - Constants

    private let pageSize = 30

    // MARK: - State

    private(set) var viewState: ViewState = .loading
    private(set) var transactions: [Transaction] = []
    private(set) var isLoadingMore = false
    private(set) var hasMorePages = true

    // MARK: - Private State

    private var currentPage = 1
    private let fetchTransactionsUseCase: FetchTransactionsUseCaseProtocol

    // MARK: - Init

    init(fetchTransactionsUseCase: FetchTransactionsUseCaseProtocol) {
        self.fetchTransactionsUseCase = fetchTransactionsUseCase
    }

    // MARK: - Public Methods

    func loadInitialTransactions() async {
        viewState = .loading

        do {
            let result = try await fetchTransactionsUseCase.execute(page: 1, results: pageSize)
            handleInitialResult(result)
            currentPage = 1
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    func loadMoreTransactions() async {
        guard !isLoadingMore, hasMorePages else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = currentPage + 1
            let result = try await fetchTransactionsUseCase.execute(page: nextPage, results: pageSize)
            appendNewTransactions(result.transactions, forPage: nextPage)
        } catch {
            // Pagination failure is silent — user can scroll again or pull-to-refresh
        }
    }

    func refresh() async {
        currentPage = 1
        hasMorePages = true

        do {
            let result = try await fetchTransactionsUseCase.execute(page: 1, results: pageSize)
            guard !result.isCached else { return }
            handleInitialResult(result)
            currentPage = 1
        } catch is CancellationError {
            // Refresh was cancelled — keep current state
        } catch {
            // If we have data, fail silently. Otherwise show error screen.
            if transactions.isEmpty {
                viewState = .error(error.localizedDescription)
            }
        }
    }

    func onTransactionAppear(transaction: Transaction) async {
        if isNearEndOfList(transaction: transaction) {
            await loadMoreTransactions()
        }
    }

    // MARK: - Private Methods

    private func handleInitialResult(_ result: FetchResult) {
        transactions = result.transactions

        if result.isCached {
            viewState = transactions.isEmpty ? .error("No cached data available.") : .loaded
            hasMorePages = false
        } else {
            viewState = .loaded
            hasMorePages = result.transactions.count >= pageSize
        }
    }

    private func appendNewTransactions(_ newTransactions: [Transaction], forPage page: Int) {
        if newTransactions.count < pageSize {
            hasMorePages = false
        }

        let uniqueNew = deduplicatedTransactions(from: newTransactions)

        if uniqueNew.isEmpty {
            hasMorePages = false
        } else {
            transactions.append(contentsOf: uniqueNew)
            currentPage = page
        }
    }

    private func deduplicatedTransactions(from newTransactions: [Transaction]) -> [Transaction] {
        let existingIDs = Set(transactions.map(\.id))
        return newTransactions.filter { !existingIDs.contains($0.id) }
    }

    private func isNearEndOfList(transaction: Transaction) -> Bool {
        guard transactions.count >= 5,
              let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            return false
        }
        return index >= transactions.count - 5
    }

}
