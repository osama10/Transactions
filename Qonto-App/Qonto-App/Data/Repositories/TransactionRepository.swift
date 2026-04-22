import Foundation

/// Concrete repository that coordinates between remote and local data sources.
/// Implements a network-first strategy with offline fallback on page 1.
struct TransactionRepository: TransactionRepositoryProtocol {

    private let remoteDataSource: TransactionRemoteDataSourceProtocol
    private let localDataSource: TransactionLocalDataSourceProtocol
    private let seed = "qonto"

    init(
        remoteDataSource: TransactionRemoteDataSourceProtocol,
        localDataSource: TransactionLocalDataSourceProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchTransactions(page: Int, results: Int) async throws -> FetchResult {
        do {
            let transactions = try await fetchRemote(page: page, results: results)
            await cacheLocally(transactions: transactions, page: page)
            return .fresh(transactions)
        } catch {
            if page == 1, let cached = await loadCachedTransactions() {
                return .cached(cached)
            }
            throw error
        }
    }

    // MARK: - Private Helpers

    private func fetchRemote(page: Int, results: Int) async throws -> [Transaction] {
        let response = try await remoteDataSource.fetchTransactions(
            page: page,
            results: results,
            seed: seed
        )
        return TransactionDTOMapper.mapToDomain(dtos: response.results)
    }

    private func cacheLocally(transactions: [Transaction], page: Int) async {
        do {
            if page == 1 {
                try await localDataSource.deleteAll()
            }
            let entities = transactions.map {
                TransactionEntityMapper.mapToEntity(domain: $0, page: page)
            }
            try await localDataSource.save(entities: entities, page: page)
        } catch {
            QontoLogger.warning("Cache save failed for page \(page): \(error.localizedDescription)", caller: Self.self)
        }
    }

    private func loadCachedTransactions() async -> [Transaction]? {
        guard await localDataSource.hasData() else { return nil }
        guard let entities = try? await localDataSource.fetchAll() else { return nil }
        return TransactionEntityMapper.mapToDomain(entities: entities)
    }
}
