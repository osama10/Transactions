import Foundation
import SwiftData

@Model
final class TransactionEntity: Persistable {
    #Unique<TransactionEntity>([\.id])
    #Index<TransactionEntity>([\.emittedAt])

    var id: String = ""
    var counterpartyName: String = ""
    var amount: Decimal = 0
    var currency: String = ""
    var emittedAt: Date = Date.distantPast
    var settledAt: Date?
    var side: String = ""
    var status: String = ""
    var operationMethod: String = ""
    var operationType: String = ""
    var descriptionText: String = ""
    var activityTag: String = ""
    var note: String?
    var initiatorName: String?
    var bankAccountName: String = ""
    var page: Int = 0

    init(
        id: String,
        counterpartyName: String,
        amount: Decimal,
        currency: String,
        emittedAt: Date,
        settledAt: Date?,
        side: String,
        status: String,
        operationMethod: String,
        operationType: String,
        descriptionText: String,
        activityTag: String,
        note: String?,
        initiatorName: String?,
        bankAccountName: String,
        page: Int
    ) {
        self.id = id
        self.counterpartyName = counterpartyName
        self.amount = amount
        self.currency = currency
        self.emittedAt = emittedAt
        self.settledAt = settledAt
        self.side = side
        self.status = status
        self.operationMethod = operationMethod
        self.operationType = operationType
        self.descriptionText = descriptionText
        self.activityTag = activityTag
        self.note = note
        self.initiatorName = initiatorName
        self.bankAccountName = bankAccountName
        self.page = page
    }
}
