import SwiftUI

struct TransactionListView: View {
    @State private var viewModel: TransactionListViewModel

    init(viewModel: TransactionListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Transactions")
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

        case .empty:
            EmptyStateView()

        case .error(let message):
            ErrorView(message: message) {
                Task {
                    await viewModel.refresh()
                }
            }

        case .offline:
            VStack(spacing: 0) {
                OfflineBannerView()
                TransactionListBody(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Transaction List Body

private struct TransactionListBody: View {
    let viewModel: TransactionListViewModel

    var body: some View {
        List {
            ForEach(viewModel.sortedTransactions) { transaction in
                TransactionRowView(viewModel: TransactionRowViewModel(transaction: transaction))
                    .task {
                        await viewModel.onTransactionAppear(transaction: transaction)
                    }
            }

            if viewModel.isLoadingMore {
                PaginationFooterView()
            }

            if let error = viewModel.paginationError {
                PaginationErrorView(message: error) {
                    Task {
                        await viewModel.loadMoreTransactions()
                    }
                }
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

// MARK: - Pagination Error

private struct PaginationErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        HStack {
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Retry", action: retryAction)
                .font(.caption)
                .buttonStyle(.bordered)
        }
        .listRowSeparator(.hidden)
    }
}

// MARK: - Preview

#Preview {
    TransactionListView(viewModel: TransactionListViewModel(
        fetchTransactionsUseCase: PreviewFetchTransactionsUseCase()
    ))
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
