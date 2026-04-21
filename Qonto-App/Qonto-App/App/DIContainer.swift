import SwiftData

/// Manual dependency injection container that wires all layers together.
/// Uses constructor injection through protocols — no singletons or global state.
@MainActor
struct DIContainer {

    let modelContainer: ModelContainer
    let viewModel: TransactionListViewModel
    let networkMonitor: NetworkMonitor

    init() {
        let modelContainer = try! PersistenceController.makeContainer(
            for: [TransactionEntity.self]
        )
        self.modelContainer = modelContainer
        let modelContext = modelContainer.mainContext

        // Core
        let networkService = URLSessionHTTPClient()
        let persistenceService = SwiftDataPersistenceService(modelContext: modelContext)
        let networkMonitor = NetworkMonitor()
        networkMonitor.start()

        // Data
        let remoteDataSource = TransactionRemoteDataSource(networkService: networkService)
        let localDataSource = TransactionLocalDataSource(persistenceService: persistenceService)

        // Repository
        let repository = TransactionRepository(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource
        )

        // Domain
        let fetchTransactionsUseCase = FetchTransactionsUseCase(repository: repository)

        // Presentation
        self.networkMonitor = networkMonitor
        viewModel = TransactionListViewModel(fetchTransactionsUseCase: fetchTransactionsUseCase)
    }
}
