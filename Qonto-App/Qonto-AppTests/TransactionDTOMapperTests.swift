import Foundation
import Testing
@testable import Qonto_App

struct TransactionDTOMapperTests {

    // MARK: - Helpers

    private func makeDTO(
        id: String = "txn-1",
        amountValue: String = "1234.56",
        currency: String = "EUR",
        counterpartyName: String = "Amazon",
        emittedAt: String = "2025-03-15T10:30:00.000Z",
        settledAt: String? = "2025-03-16T14:00:00.000Z",
        side: String = "DEBIT",
        status: String = "COMPLETED",
        operationMethod: String = "CARD",
        operationType: String = "CARD",
        description: String = "Office supplies",
        activityTag: String = "OTHER_EXPENSE",
        note: String? = "Monthly order",
        initiator: InitiatorDTO? = InitiatorDTO(id: "usr-1", fullName: "Alice Martin"),
        bankAccount: BankAccountDTO = BankAccountDTO(id: "acc-1", name: "Main Account")
    ) -> TransactionDTO {
        TransactionDTO(
            id: id,
            amount: AmountDTO(value: amountValue, currency: currency),
            counterpartyName: counterpartyName,
            emittedAt: emittedAt,
            settledAt: settledAt,
            side: side,
            status: status,
            operationMethod: operationMethod,
            operationType: operationType,
            description: description,
            activityTag: activityTag,
            note: note,
            initiator: initiator,
            bankAccount: bankAccount
        )
    }

    // MARK: - Happy Path

    @Test func happyPath_mapsAllFieldsCorrectly() throws {
        let dto = makeDTO()
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)

        #expect(result.id == "txn-1")
        #expect(result.counterpartyName == "Amazon")
        #expect(result.amount == Decimal(string: "1234.56"))
        #expect(result.currency == "EUR")
        #expect(result.side == .debit)
        #expect(result.status == .completed)
        #expect(result.operationMethod == .card)
        #expect(result.operationType == .card)
        #expect(result.description == "Office supplies")
        #expect(result.activityTag == .otherExpense)
        #expect(result.note == "Monthly order")
        #expect(result.initiatorName == "Alice Martin")
        #expect(result.bankAccountName == "Main Account")
    }

    // MARK: - Amount Parsing

    @Test func amountParsing_stringToDecimal() throws {
        let dto = makeDTO(amountValue: "9999.99")
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)

        #expect(result.amount == Decimal(string: "9999.99"))
    }

    @Test func invalidAmount_throws() {
        let dto = makeDTO(amountValue: "not-a-number")

        #expect(throws: MappingError.self) {
            try TransactionDTOMapper.mapToDomain(dto: dto)
        }
    }

    // MARK: - Date Parsing

    @Test func dateParsing_iso8601ToDate() throws {
        let dto = makeDTO(emittedAt: "2025-03-15T10:30:00.000Z")
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)

        #expect(result.emittedAt != Date.distantPast)
    }

    @Test func invalidDate_throws() {
        let dto = makeDTO(emittedAt: "not-a-date")

        #expect(throws: MappingError.self) {
            try TransactionDTOMapper.mapToDomain(dto: dto)
        }
    }

    // MARK: - Enum Mapping

    @Test(arguments: [
        ("CREDIT", TransactionSide.credit),
        ("DEBIT", TransactionSide.debit)
    ])
    func sideMapping(raw: String, expected: TransactionSide) throws {
        let dto = makeDTO(side: raw)
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)
        #expect(result.side == expected)
    }

    @Test(arguments: [
        ("COMPLETED", TransactionStatus.completed),
        ("PENDING", TransactionStatus.pending),
        ("DECLINED", TransactionStatus.declined)
    ])
    func statusMapping(raw: String, expected: TransactionStatus) throws {
        let dto = makeDTO(status: raw)
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)
        #expect(result.status == expected)
    }

    @Test(arguments: [
        ("TRANSFER", OperationMethod.transfer),
        ("CARD", OperationMethod.card),
        ("DIRECT_DEBIT", OperationMethod.directDebit)
    ])
    func operationMethodMapping(raw: String, expected: OperationMethod) throws {
        let dto = makeDTO(operationMethod: raw)
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)
        #expect(result.operationMethod == expected)
    }

    @Test(arguments: [
        ("INCOME", OperationType.income),
        ("TRANSFER", OperationType.transfer),
        ("CARD", OperationType.card)
    ])
    func operationTypeMapping(raw: String, expected: OperationType) throws {
        let dto = makeDTO(operationType: raw)
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)
        #expect(result.operationType == expected)
    }

    @Test(arguments: [
        ("OTHER_INCOME", ActivityTag.otherIncome),
        ("OTHER_EXPENSE", ActivityTag.otherExpense),
        ("OTHER_SERVICE", ActivityTag.otherService),
        ("REFUND", ActivityTag.refund),
        ("FEES", ActivityTag.fees)
    ])
    func activityTagMapping(raw: String, expected: ActivityTag) throws {
        let dto = makeDTO(activityTag: raw)
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)
        #expect(result.activityTag == expected)
    }

    @Test func invalidEnumValue_throws() {
        let dto = makeDTO(side: "UNKNOWN")

        #expect(throws: MappingError.self) {
            try TransactionDTOMapper.mapToDomain(dto: dto)
        }
    }

    // MARK: - Optional Handling

    @Test func optionalsNil_mappedCorrectly() throws {
        let dto = makeDTO(settledAt: nil, note: nil, initiator: nil)
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)

        #expect(result.settledAt == nil)
        #expect(result.note == nil)
        #expect(result.initiatorName == nil)
    }

    @Test func optionalsPresent_mappedCorrectly() throws {
        let dto = makeDTO(
            settledAt: "2025-03-16T14:00:00.000Z",
            note: "A note",
            initiator: InitiatorDTO(id: "usr-1", fullName: "Bob Smith")
        )
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)

        #expect(result.settledAt != nil)
        #expect(result.note == "A note")
        #expect(result.initiatorName == "Bob Smith")
    }

    // MARK: - Initiator & Bank Account Flattening

    @Test func initiatorFlattening() throws {
        let dto = makeDTO(initiator: InitiatorDTO(id: "usr-99", fullName: "Jane Doe"))
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)

        #expect(result.initiatorName == "Jane Doe")
    }

    @Test func bankAccountFlattening() throws {
        let dto = makeDTO(bankAccount: BankAccountDTO(id: "acc-2", name: "Savings"))
        let result = try TransactionDTOMapper.mapToDomain(dto: dto)

        #expect(result.bankAccountName == "Savings")
    }

    // MARK: - Array Mapping

    @Test func arrayMapping_filtersOutInvalidDTOs() {
        let validDTO = makeDTO(id: "valid-1")
        let invalidDTO = makeDTO(id: "invalid-1", amountValue: "not-a-number")
        let validDTO2 = makeDTO(id: "valid-2")

        let results = TransactionDTOMapper.mapToDomain(dtos: [validDTO, invalidDTO, validDTO2])

        #expect(results.count == 2)
        #expect(results[0].id == "valid-1")
        #expect(results[1].id == "valid-2")
    }

    @Test func arrayMapping_allInvalid_returnsEmpty() {
        let invalid1 = makeDTO(amountValue: "bad")
        let invalid2 = makeDTO(emittedAt: "bad")

        let results = TransactionDTOMapper.mapToDomain(dtos: [invalid1, invalid2])

        #expect(results.isEmpty)
    }
}
