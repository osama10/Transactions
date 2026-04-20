import Foundation

/// A marker protocol for any model that can be persisted.
/// Storage-specific models (SwiftData, Core Data, Realm, etc.) must conform to this protocol.
protocol Persistable: Sendable, Hashable {}
