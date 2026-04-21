import SwiftUI

struct TransactionRowView: View {
    let viewModel: TransactionRowViewModel

    var body: some View {
        VStack(alignment: .leading) {
            // Line 1: Icon + Counterparty Name | Amount
            HStack {
                Label(viewModel.counterpartyName, systemImage: viewModel.operationIconName)
                    .font(.body)
                    .bold()
                    .lineLimit(1)

                Spacer()

                Text(viewModel.formattedAmount)
                    .font(.body)
                    .bold()
                    .foregroundStyle(viewModel.amountColor)
            }

            // Line 2: Method + Description | Status Badge
            HStack {
                Text(viewModel.methodDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                Text(viewModel.statusLabel)
                    .font(.caption2)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .foregroundStyle(.white)
                    .background(viewModel.statusColor, in: .capsule)
            }

            // Line 3: Date
            Text(viewModel.formattedDate)
                .font(.caption)
                .foregroundStyle(.tertiary)

            // Optional: Initiator name
            if let initiatorText = viewModel.initiatorText {
                Text(initiatorText)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Preview

#Preview {
    List {
        TransactionRowView(viewModel: TransactionRowViewModel(transaction: Transaction(
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
        )))

        TransactionRowView(viewModel: TransactionRowViewModel(transaction: Transaction(
            id: "2",
            counterpartyName: "Client Payment",
            amount: 5000.00,
            currency: "EUR",
            emittedAt: .now,
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
        )))

        TransactionRowView(viewModel: TransactionRowViewModel(transaction: Transaction(
            id: "3",
            counterpartyName: "Failed Payment",
            amount: 99.99,
            currency: "EUR",
            emittedAt: .now,
            settledAt: nil,
            side: .debit,
            status: .declined,
            operationMethod: .directDebit,
            operationType: .transfer,
            description: "",
            activityTag: .fees,
            note: nil,
            initiatorName: nil,
            bankAccountName: "Main Account"
        )))
    }
}
