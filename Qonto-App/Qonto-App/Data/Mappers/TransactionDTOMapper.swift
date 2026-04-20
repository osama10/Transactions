import Foundation

struct TransactionDTOMapper {

    private static let iso8601Strategy = Date.ISO8601FormatStyle(includingFractionalSeconds: true)

    static func mapToDomain(dto: TransactionDTO) throws(MappingError) -> Transaction {
        guard let amount = Decimal(string: dto.amount.value) else {
            throw .invalidAmount(dto.amount.value)
        }

        guard let emittedAt = try? iso8601Strategy.parse(dto.emittedAt) else {
            throw .invalidDate(dto.emittedAt)
        }

        guard let side = TransactionSide(rawValue: dto.side) else {
            throw .invalidEnumValue(field: "side", value: dto.side)
        }

        guard let status = TransactionStatus(rawValue: dto.status) else {
            throw .invalidEnumValue(field: "status", value: dto.status)
        }

        guard let operationMethod = OperationMethod(rawValue: dto.operationMethod) else {
            throw .invalidEnumValue(field: "operationMethod", value: dto.operationMethod)
        }

        guard let operationType = OperationType(rawValue: dto.operationType) else {
            throw .invalidEnumValue(field: "operationType", value: dto.operationType)
        }

        guard let activityTag = ActivityTag(rawValue: dto.activityTag) else {
            throw .invalidEnumValue(field: "activityTag", value: dto.activityTag)
        }

        let settledAt: Date? = if let settledAtString = dto.settledAt {
            try? iso8601Strategy.parse(settledAtString)
        } else {
            nil
        }

        return Transaction(
            id: dto.id,
            counterpartyName: dto.counterpartyName,
            amount: amount,
            currency: dto.amount.currency,
            emittedAt: emittedAt,
            settledAt: settledAt,
            side: side,
            status: status,
            operationMethod: operationMethod,
            operationType: operationType,
            description: dto.description,
            activityTag: activityTag,
            note: dto.note,
            initiatorName: dto.initiator?.fullName,
            bankAccountName: dto.bankAccount.name
        )
    }

    static func mapToDomain(dtos: [TransactionDTO]) -> [Transaction] {
        dtos.compactMap { try? mapToDomain(dto: $0) }
    }
}
