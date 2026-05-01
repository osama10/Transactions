import Foundation

/// Protocol defining the use case for fetching transactions.
/// Provides a testable boundary between the ViewModel and the Repository.
protocol FetchTransactionsUseCaseProtocol: Sendable {
    func execute(page: Int, results: Int) async throws -> FetchResult
}

/// Concrete implementation that delegates to the repository.
struct FetchTransactionsUseCase: FetchTransactionsUseCaseProtocol {
    private let repository: any TransactionRepositoryProtocol

    init(repository: any TransactionRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int, results: Int) async throws -> FetchResult {
        try await repository.fetchTransactions(page: page, results: results)
    }
}
