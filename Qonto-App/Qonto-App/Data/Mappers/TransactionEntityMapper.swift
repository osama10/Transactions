import Foundation

struct TransactionEntityMapper {

    // MARK: - Domain -> Entity

    static func mapToEntity(domain: Transaction, page: Int) -> TransactionEntity {
        TransactionEntity(
            id: domain.id,
            counterpartyName: domain.counterpartyName,
            amount: domain.amount,
            currency: domain.currency,
            emittedAt: domain.emittedAt,
            settledAt: domain.settledAt,
            side: domain.side.rawValue,
            status: domain.status.rawValue,
            operationMethod: domain.operationMethod.rawValue,
            operationType: domain.operationType.rawValue,
            descriptionText: domain.description,
            activityTag: domain.activityTag.rawValue,
            note: domain.note,
            initiatorName: domain.initiatorName,
            bankAccountName: domain.bankAccountName,
            page: page
        )
    }

    // MARK: - Entity -> Domain

    static func mapToDomain(entity: TransactionEntity) throws(MappingError) -> Transaction {
        guard let side = TransactionSide(rawValue: entity.side) else {
            throw .invalidEnumValue(field: "side", value: entity.side)
        }

        guard let status = TransactionStatus(rawValue: entity.status) else {
            throw .invalidEnumValue(field: "status", value: entity.status)
        }

        guard let operationMethod = OperationMethod(rawValue: entity.operationMethod) else {
            throw .invalidEnumValue(field: "operationMethod", value: entity.operationMethod)
        }

        guard let operationType = OperationType(rawValue: entity.operationType) else {
            throw .invalidEnumValue(field: "operationType", value: entity.operationType)
        }

        guard let activityTag = ActivityTag(rawValue: entity.activityTag) else {
            throw .invalidEnumValue(field: "activityTag", value: entity.activityTag)
        }

        return Transaction(
            id: entity.id,
            counterpartyName: entity.counterpartyName,
            amount: entity.amount,
            currency: entity.currency,
            emittedAt: entity.emittedAt,
            settledAt: entity.settledAt,
            side: side,
            status: status,
            operationMethod: operationMethod,
            operationType: operationType,
            description: entity.descriptionText,
            activityTag: activityTag,
            note: entity.note,
            initiatorName: entity.initiatorName,
            bankAccountName: entity.bankAccountName
        )
    }

    static func mapToDomain(entities: [TransactionEntity]) -> [Transaction] {
        entities.compactMap { try? mapToDomain(entity: $0) }
    }
}
