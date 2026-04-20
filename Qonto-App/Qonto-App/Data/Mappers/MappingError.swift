import Foundation

enum MappingError: Error, Sendable {
    case invalidAmount(String)
    case invalidDate(String)
    case invalidEnumValue(field: String, value: String)
}
