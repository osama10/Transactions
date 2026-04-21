import Foundation

/// A generic persistence layer abstraction.
/// The underlying storage technology (SwiftData, Core Data, etc.) is an implementation detail.
/// All operations are `@MainActor`-isolated since the app uses `mainContext`.
@MainActor
protocol PersistenceServicing {

    /// Fetches records matching the given predicate and sort order.
    func fetch<T: Persistable>(
        _ type: T.Type,
        predicate: Predicate<T>?,
        sortBy: [SortDescriptor<T>]
    ) throws -> [T]

    /// Returns the count of all records of the given type.
    func count<T: Persistable>(_ type: T.Type) throws -> Int

    /// Inserts a new record into the store.
    func insert<T: Persistable>(_ model: T) throws

    /// Deletes a specific record from the store.
    func delete<T: Persistable>(_ model: T) throws

    /// Deletes all records of the given type.
    func deleteAll<T: Persistable>(_ type: T.Type) throws
}

extension PersistenceServicing {
    /// Convenience: fetches all records of the given type with no filtering or sorting.
    func fetchAll<T: Persistable>(_ type: T.Type) throws -> [T] {
        try fetch(type, predicate: nil, sortBy: [])
    }
}
