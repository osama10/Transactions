import Foundation

enum PersistenceError: Error, Sendable {
    case incompatibleModelType
    case saveFailed(Error)
}
