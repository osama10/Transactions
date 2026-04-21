import Foundation
@testable import Qonto_App

final class MockTransactionRemoteDataSource: TransactionRemoteDataSourceProtocol, @unchecked Sendable {
    var responseToReturn: TransactionResponse?
    var errorToThrow: NetworkError?
    var callCount = 0
    var lastPage: Int?

    func fetchTransactions(page: Int, results: Int, seed: String) async throws(NetworkError) -> TransactionResponse {
        callCount += 1
        lastPage = page
        if let error = errorToThrow {
            throw error
        }
        return responseToReturn!
    }
}
