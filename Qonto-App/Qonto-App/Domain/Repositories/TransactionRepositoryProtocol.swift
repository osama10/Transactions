import Foundation

/// Defines the contract for fetching and caching transactions.
/// The Domain layer owns this protocol; the Data layer implements it.
protocol TransactionRepositoryProtocol: Sendable {

    /// Fetches transactions for the given page.
    /// Returns `.fresh` for remote data or `.cached` for offline fallback (page 1 only).
    func fetchTransactions(page: Int, results: Int) async throws -> FetchResult
}
