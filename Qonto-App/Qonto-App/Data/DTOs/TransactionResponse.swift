import Foundation

struct TransactionResponse: Codable, Sendable {
    let results: [TransactionDTO]
    let info: InfoDTO
}

struct TransactionDTO: Codable, Sendable {
    let id: String
    let amount: AmountDTO
    let counterpartyName: String
    let emittedAt: String
    let settledAt: String?
    let side: String
    let status: String
    let operationMethod: String
    let operationType: String
    let description: String
    let activityTag: String
    let note: String?
    let initiator: InitiatorDTO?
    let bankAccount: BankAccountDTO
}

struct AmountDTO: Codable, Sendable {
    let value: String
    let currency: String
}

struct InitiatorDTO: Codable, Sendable {
    let id: String
    let fullName: String
}

struct BankAccountDTO: Codable, Sendable {
    let id: String
    let name: String
}

struct InfoDTO: Codable, Sendable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}
