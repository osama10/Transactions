import SwiftUI

struct TransactionListView: View {
    @State private var viewModel: TransactionListViewModel
    var networkMonitor: NetworkMonitor

    init(viewModel: TransactionListViewModel, networkMonitor: NetworkMonitor) {
        self.viewModel = viewModel
        self.networkMonitor = networkMonitor
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Transactions")
                .safeAreaInset(edge: .top) {
                    if !networkMonitor.isConnected {
                        OfflineBannerView()
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(.default, value: networkMonitor.isConnected)
        }
        .task {
            await viewModel.loadInitialTransactions()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            LoadingView()

        case .loaded:
            TransactionListBody(viewModel: viewModel)

        case .error(let message):
            ErrorView(message: message) {
                Task {
                    await viewModel.loadInitialTransactions()
                }
            }
        }
    }
}

// MARK: - Transaction List Body

private struct TransactionListBody: View {
    let viewModel: TransactionListViewModel

    var body: some View {
        List {
            ForEach(viewModel.transactions) { transaction in
                TransactionRowView(viewModel: TransactionRowViewModel(transaction: transaction))
                    .task {
                        await viewModel.onTransactionAppear(transaction: transaction)
                    }
            }

            if viewModel.isLoadingMore {
                PaginationFooterView()
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Pagination Footer

private struct PaginationFooterView: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .listRowSeparator(.hidden)
    }
}

// MARK: - Preview

#Preview {
    TransactionListView(
        viewModel: TransactionListViewModel(
            fetchTransactionsUseCase: PreviewFetchTransactionsUseCase()
        ),
        networkMonitor: NetworkMonitor()
    )
}

/// A mock use case for SwiftUI previews.
private struct PreviewFetchTransactionsUseCase: FetchTransactionsUseCaseProtocol {
    func execute(page: Int, results: Int) async throws -> FetchResult {
        .fresh([
            Transaction(
                id: "1",
                counterpartyName: "Amazon",
                amount: 1234.56,
                currency: "EUR",
                emittedAt: .now,
                settledAt: .now,
                side: .debit,
                status: .completed,
                operationMethod: .card,
                operationType: .card,
                description: "Office supplies",
                activityTag: .otherExpense,
                note: nil,
                initiatorName: "Alice Martin",
                bankAccountName: "Main Account"
            ),
            Transaction(
                id: "2",
                counterpartyName: "Client Payment",
                amount: 5000.00,
                currency: "EUR",
                emittedAt: .now.addingTimeInterval(-86400),
                settledAt: nil,
                side: .credit,
                status: .pending,
                operationMethod: .transfer,
                operationType: .income,
                description: "Invoice #1234",
                activityTag: .otherIncome,
                note: nil,
                initiatorName: nil,
                bankAccountName: "Main Account"
            )
        ])
    }
}
