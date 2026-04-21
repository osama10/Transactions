import Foundation

@MainActor
@Observable
final class TransactionListViewModel {

    // MARK: - ViewState

    enum ViewState: Equatable {
        case loading
        case loaded
        case empty
        case error(String)
        case offline
    }

    // MARK: - Constants

    private let pageSize = 30

    // MARK: - Published State

    private(set) var viewState: ViewState = .loading
    private(set) var sortedTransactions: [Transaction] = []
    private(set) var isLoadingMore = false
    private(set) var hasMorePages = true
    private(set) var paginationError: String?

    // MARK: - Private State

    private var transactions: [Transaction] = [] {
        didSet { sortedTransactions = transactions.sorted { $0.emittedAt > $1.emittedAt } }
    }
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
        paginationError = nil
        defer { isLoadingMore = false }

        do {
            let nextPage = currentPage + 1
            let result = try await fetchTransactionsUseCase.execute(page: nextPage, results: pageSize)
            appendNewTransactions(result.transactions, forPage: nextPage)
        } catch {
            paginationError = error.localizedDescription
        }
    }

    func refresh() async {
        resetPaginationState()
        await loadInitialTransactions()
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
            viewState = .offline
            hasMorePages = false
        } else {
            viewState = transactions.isEmpty ? .empty : .loaded
            // If results == pageSize, we assume more pages exist. This may trigger one
            // extra fetch that returns fewer results, which then sets hasMorePages to false.
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

    private func resetPaginationState() {
        currentPage = 1
        hasMorePages = true
        transactions = []
        paginationError = nil
    }

    private func isNearEndOfList(transaction: Transaction) -> Bool {
        guard sortedTransactions.count >= 5,
              let index = sortedTransactions.firstIndex(where: { $0.id == transaction.id }) else {
            return false
        }
        return index >= sortedTransactions.count - 5
    }
}
