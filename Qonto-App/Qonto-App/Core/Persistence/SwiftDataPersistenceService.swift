import Foundation
import SwiftData

/// Concrete implementation of `PersistenceServicing` backed by SwiftData.
/// All operations run on `mainContext`.
/// Models passed in must conform to both `Persistable` and `PersistentModel`.
@MainActor
struct SwiftDataPersistenceService: PersistenceServicing {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetch<T: Persistable>(
        _ type: T.Type,
        predicate: Predicate<T>?,
        sortBy: [SortDescriptor<T>]
    ) throws -> [T] {
        guard let persistentType = type as? any PersistentModel.Type else {
            throw PersistenceError.incompatibleModelType
        }
        // Implicit existential opening binds the concrete type to M in performFetch.
        // At runtime T == M, so the predicate/sort casts always succeed.
        guard let results = try performFetch(persistentType, predicate: predicate, sortBy: sortBy) as? [T] else {
            throw PersistenceError.incompatibleModelType
        }
        return results
    }

    func count<T: Persistable>(_ type: T.Type) throws -> Int {
        guard let persistentType = type as? any PersistentModel.Type else {
            throw PersistenceError.incompatibleModelType
        }
        return try performCount(persistentType)
    }

    func insert<T: Persistable>(_ model: T) throws {
        guard let persistentModel = model as? any PersistentModel else {
            throw PersistenceError.incompatibleModelType
        }
        modelContext.insert(persistentModel)
    }

    func delete<T: Persistable>(_ model: T) throws {
        guard let persistentModel = model as? any PersistentModel else {
            throw PersistenceError.incompatibleModelType
        }
        modelContext.delete(persistentModel)
    }

    func deleteAll<T: Persistable>(_ type: T.Type) throws {
        guard let persistentType = type as? any PersistentModel.Type else {
            throw PersistenceError.incompatibleModelType
        }
        try performDeleteAll(persistentType)
    }

    // MARK: - SwiftData Operations

    private func performFetch<M: PersistentModel>(
        _: M.Type,
        predicate: Any?,
        sortBy: Any
    ) throws -> [M] {
        var descriptor = FetchDescriptor<M>()
        descriptor.predicate = predicate as? Predicate<M>
        if let sortDescriptors = sortBy as? [SortDescriptor<M>] {
            descriptor.sortBy = sortDescriptors
        }
        return try modelContext.fetch(descriptor)
    }

    private func performCount<M: PersistentModel>(_: M.Type) throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<M>())
    }

    private func performDeleteAll<M: PersistentModel>(_ type: M.Type) throws {
        try modelContext.delete(model: type)
    }
}
