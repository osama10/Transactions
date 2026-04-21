import Foundation

/// Protocol defining the contract for fetching transactions from the remote API.
protocol TransactionRemoteDataSourceProtocol: Sendable {
    func fetchTransactions(page: Int, results: Int, seed: String) async throws(NetworkError) -> TransactionResponse
}

/// Concrete implementation that fetches transactions from the remote API using the networking layer.
struct TransactionRemoteDataSource: TransactionRemoteDataSourceProtocol {
    private let networkService: NetworkServicing

    init(networkService: NetworkServicing) {
        self.networkService = networkService
    }

    func fetchTransactions(page: Int, results: Int, seed: String) async throws(NetworkError) -> TransactionResponse {
        let request = APIEndpoint.transactions(page: page, results: results, seed: seed)
        return try await networkService.send(request)
    }
}
