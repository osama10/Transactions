import Foundation
@testable import Qonto_App

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
