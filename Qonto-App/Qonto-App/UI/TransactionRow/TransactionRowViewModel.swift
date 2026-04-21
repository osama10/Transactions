import SwiftUI

struct TransactionRowViewModel {
    let counterpartyName: String
    let operationIconName: String
    let formattedAmount: String
    let amountColor: Color
    let methodDescription: String
    let statusLabel: String
    let statusColor: Color
    let formattedEmittedAt: String
    let formattedSettledAt: String?
    let initiatorText: String?

    init(transaction: Transaction) {
        counterpartyName = transaction.counterpartyName
        operationIconName = Self.iconName(for: transaction.operationMethod)
        formattedAmount = Self.formatAmount(transaction.amount, currency: transaction.currency, side: transaction.side)
        amountColor = transaction.side == .credit ? .green : .primary
        methodDescription = Self.buildMethodDescription(method: transaction.operationMethod, description: transaction.description)
        statusLabel = Self.label(for: transaction.status)
        statusColor = Self.color(for: transaction.status)
        formattedEmittedAt = "Emitted: \(transaction.emittedAt.formatted(date: .abbreviated, time: .shortened))"
        formattedSettledAt = transaction.settledAt.map { "Settled: \($0.formatted(date: .abbreviated, time: .shortened))" }
        initiatorText = transaction.initiatorName.map { "by \($0)" }
    }

    // MARK: - Formatting Helpers

    private static func iconName(for method: OperationMethod) -> String {
        switch method {
        case .card: "creditcard"
        case .transfer: "arrow.left.arrow.right"
        case .directDebit: "building.columns"
        }
    }

    private static func formatAmount(_ amount: Decimal, currency: String, side: TransactionSide) -> String {
        let prefix = side == .credit ? "+" : "-"
        let absoluteAmount = amount < 0 ? -amount : amount
        let formatted = absoluteAmount.formatted(.number.precision(.fractionLength(2)))
        return "\(prefix)\(currency) \(formatted)"
    }

    private static func buildMethodDescription(method: OperationMethod, description: String) -> String {
        let methodLabel: String = switch method {
        case .card: "Card"
        case .transfer: "Transfer"
        case .directDebit: "Direct Debit"
        }
        if description.isEmpty {
            return methodLabel
        }
        return "\(methodLabel) - \(description)"
    }

    private static func label(for status: TransactionStatus) -> String {
        switch status {
        case .completed: "Completed"
        case .pending: "Pending"
        case .declined: "Declined"
        }
    }

    private static func color(for status: TransactionStatus) -> Color {
        switch status {
        case .completed: .green
        case .pending: .orange
        case .declined: .red
        }
    }

}
