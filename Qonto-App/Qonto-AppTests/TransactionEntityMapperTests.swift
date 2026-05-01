import Foundation
import Testing
@testable import Qonto_App

struct TransactionEntityMapperTests {

    // MARK: - Helpers

    private let sampleDate = Date(timeIntervalSince1970: 1710500000)
    private let sampleSettledDate = Date(timeIntervalSince1970: 1710600000)

    private func makeDomainTransaction(
        id: String = "txn-1",
        counterpartyName: String = "Amazon",
        amount: Decimal = 1234.56,
        currency: String = "EUR",
        emittedAt: Date? = nil,
        settledAt: Date? = Date(timeIntervalSince1970: 1710600000),
        side: TransactionSide = .debit,
        status: TransactionStatus = .completed,
        operationMethod: OperationMethod = .card,
        operationType: OperationType = .card,
        description: String = "Office supplies",
        activityTag: ActivityTag = .otherExpense,
        note: String? = "A note",
        initiatorName: String? = "Alice Martin",
        bankAccountName: String = "Main Account"
    ) -> Transaction {
        Transaction(
            id: id,
            counterpartyName: counterpartyName,
            amount: amount,
            currency: currency,
            emittedAt: emittedAt ?? sampleDate,
            settledAt: settledAt,
            side: side,
            status: status,
            operationMethod: operationMethod,
            operationType: operationType,
            description: description,
            activityTag: activityTag,
            note: note,
            initiatorName: initiatorName,
            bankAccountName: bankAccountName
        )
    }

    private func makeEntity(
        id: String = "txn-1",
        side: String = "DEBIT",
        status: String = "COMPLETED",
        operationMethod: String = "CARD",
        operationType: String = "CARD",
        activityTag: String = "OTHER_EXPENSE",
        page: Int = 1
    ) -> TransactionEntity {
        TransactionEntity(
            id: id,
            counterpartyName: "Amazon",
            amount: 1234.56,
            currency: "EUR",
            emittedAt: sampleDate,
            settledAt: sampleSettledDate,
            side: side,
            status: status,
            operationMethod: operationMethod,
            operationType: operationType,
            descriptionText: "Office supplies",
            activityTag: activityTag,
            note: "A note",
            initiatorName: "Alice Martin",
            bankAccountName: "Main Account",
            page: page
        )
    }

    // MARK: - Domain -> Entity

    @Test func domainToEntity_mapsAllFields() {
        let domain = makeDomainTransaction()
        let entity = TransactionEntityMapper.mapToEntity(domain: domain, page: 3)

        #expect(entity.id == "txn-1")
        #expect(entity.counterpartyName == "Amazon")
        #expect(entity.amount == 1234.56)
        #expect(entity.currency == "EUR")
        #expect(entity.emittedAt == sampleDate)
        #expect(entity.settledAt == sampleSettledDate)
        #expect(entity.side == "DEBIT")
        #expect(entity.status == "COMPLETED")
        #expect(entity.operationMethod == "CARD")
        #expect(entity.operationType == "CARD")
        #expect(entity.descriptionText == "Office supplies")
        #expect(entity.activityTag == "OTHER_EXPENSE")
        #expect(entity.note == "A note")
        #expect(entity.initiatorName == "Alice Martin")
        #expect(entity.bankAccountName == "Main Account")
        #expect(entity.page == 3)
    }

    // MARK: - Entity -> Domain

    @Test func entityToDomain_mapsAllFields() throws {
        let entity = makeEntity()
        let result = try TransactionEntityMapper.mapToDomain(entity: entity)

        #expect(result.id == "txn-1")
        #expect(result.counterpartyName == "Amazon")
        #expect(result.amount == 1234.56)
        #expect(result.currency == "EUR")
        #expect(result.emittedAt == sampleDate)
        #expect(result.settledAt == sampleSettledDate)
        #expect(result.side == .debit)
        #expect(result.status == .completed)
        #expect(result.operationMethod == .card)
        #expect(result.operationType == .card)
        #expect(result.description == "Office supplies")
        #expect(result.activityTag == .otherExpense)
        #expect(result.note == "A note")
        #expect(result.initiatorName == "Alice Martin")
        #expect(result.bankAccountName == "Main Account")
    }

    // MARK: - Round-trip

    @Test func roundTrip_domainToEntityToDomain() throws {
        let original = makeDomainTransaction()
        let entity = TransactionEntityMapper.mapToEntity(domain: original, page: 1)
        let result = try TransactionEntityMapper.mapToDomain(entity: entity)

        #expect(result == original)
    }

    // MARK: - Optional Handling

    @Test func optionalsNil_surviveRoundTrip() throws {
        let original = makeDomainTransaction(settledAt: nil, note: nil, initiatorName: nil)
        let entity = TransactionEntityMapper.mapToEntity(domain: original, page: 1)
        let result = try TransactionEntityMapper.mapToDomain(entity: entity)

        #expect(result.settledAt == nil)
        #expect(result.note == nil)
        #expect(result.initiatorName == nil)
        #expect(result == original)
    }

    // MARK: - Page Field

    @Test func pageField_correctlySetOnEntity() {
        let domain = makeDomainTransaction()

        let entity1 = TransactionEntityMapper.mapToEntity(domain: domain, page: 1)
        let entity5 = TransactionEntityMapper.mapToEntity(domain: domain, page: 5)

        #expect(entity1.page == 1)
        #expect(entity5.page == 5)
    }

    // MARK: - Invalid Entity

    @Test func invalidSide_throws() {
        let entity = makeEntity(side: "UNKNOWN")

        #expect(throws: MappingError.self) {
            try TransactionEntityMapper.mapToDomain(entity: entity)
        }
    }

    @Test func invalidStatus_throws() {
        let entity = makeEntity(status: "UNKNOWN")

        #expect(throws: MappingError.self) {
            try TransactionEntityMapper.mapToDomain(entity: entity)
        }
    }

    @Test func invalidOperationMethod_throws() {
        let entity = makeEntity(operationMethod: "UNKNOWN")

        #expect(throws: MappingError.self) {
            try TransactionEntityMapper.mapToDomain(entity: entity)
        }
    }

    @Test func invalidOperationType_throws() {
        let entity = makeEntity(operationType: "UNKNOWN")

        #expect(throws: MappingError.self) {
            try TransactionEntityMapper.mapToDomain(entity: entity)
        }
    }

    @Test func invalidActivityTag_throws() {
        let entity = makeEntity(activityTag: "UNKNOWN")

        #expect(throws: MappingError.self) {
            try TransactionEntityMapper.mapToDomain(entity: entity)
        }
    }

    // MARK: - Array Mapping

    @Test func arrayMapping_filtersOutInvalidEntities() {
        let valid = makeEntity(id: "valid-1")
        let invalid = makeEntity(id: "invalid-1", side: "BAD")
        let valid2 = makeEntity(id: "valid-2")

        let results = TransactionEntityMapper.mapToDomain(entities: [valid, invalid, valid2])

        #expect(results.count == 2)
        #expect(results[0].id == "valid-1")
        #expect(results[1].id == "valid-2")
    }
}
