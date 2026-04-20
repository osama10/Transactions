import Foundation

struct Transaction: Sendable, Hashable, Identifiable {
    let id: String
    let counterpartyName: String
    let amount: Decimal
    let currency: String
    let emittedAt: Date
    let settledAt: Date?
    let side: TransactionSide
    let status: TransactionStatus
    let operationMethod: OperationMethod
    let operationType: OperationType
    let description: String
    let activityTag: ActivityTag
    let note: String?
    let initiatorName: String?
    let bankAccountName: String
}

enum TransactionSide: String, Sendable, Hashable {
    case credit = "CREDIT"
    case debit = "DEBIT"
}

enum TransactionStatus: String, Sendable, Hashable {
    case completed = "COMPLETED"
    case pending = "PENDING"
    case declined = "DECLINED"
}

enum OperationMethod: String, Sendable, Hashable {
    case transfer = "TRANSFER"
    case card = "CARD"
    case directDebit = "DIRECT_DEBIT"
}

enum OperationType: String, Sendable, Hashable {
    case income = "INCOME"
    case transfer = "TRANSFER"
    case card = "CARD"
}

enum ActivityTag: String, Sendable, Hashable {
    case otherIncome = "OTHER_INCOME"
    case otherExpense = "OTHER_EXPENSE"
    case otherService = "OTHER_SERVICE"
    case refund = "REFUND"
    case fees = "FEES"
}
