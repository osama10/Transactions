import Foundation

/// Defines the contract for fetching and caching transactions.
/// The Domain layer owns this protocol; the Data layer implements it.
protocol TransactionRepositoryProtocol: Sendable {

    /// Fetches transactions for the given page.
    /// The implementation handles remote fetch, local fallback, caching, and mapping.
    func fetchTransactions(page: Int, results: Int) async throws -> [Transaction]

    /// Clears all locally cached transactions (e.g. for pull-to-refresh).
    func clearCache() async throws
}
