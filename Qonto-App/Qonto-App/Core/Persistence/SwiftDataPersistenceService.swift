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

    func fetchAll<T: Persistable>(_ type: T.Type) throws -> [T] {
        let persistentType = try toPersistentModelType(type)
        guard let results = try performFetch(persistentType) as? [T] else {
            throw PersistenceError.incompatibleModelType
        }
        return results
    }

    func count<T: Persistable>(_ type: T.Type) throws -> Int {
        let persistentType = try toPersistentModelType(type)
        return try performCount(persistentType)
    }

    func insert<T: Persistable>(_ model: T) throws {
        let persistentModel = try toPersistentModel(model)
        modelContext.insert(persistentModel)
    }

    func delete<T: Persistable>(_ model: T) throws {
        let persistentModel = try toPersistentModel(model)
        modelContext.delete(persistentModel)
    }

    func deleteAll<T: Persistable>(_ type: T.Type) throws {
        let persistentType = try toPersistentModelType(type)
        try performDeleteAll(persistentType)
    }

    func save() throws {
        try modelContext.save()
    }

    // MARK: - Type Casting

    private func toPersistentModelType<T: Persistable>(_ type: T.Type) throws -> any PersistentModel.Type {
        guard let persistentType = type as? any PersistentModel.Type else {
            throw PersistenceError.incompatibleModelType
        }
        return persistentType
    }

    private func toPersistentModel<T: Persistable>(_ model: T) throws -> any PersistentModel {
        guard let persistentModel = model as? any PersistentModel else {
            throw PersistenceError.incompatibleModelType
        }
        return persistentModel
    }

    // MARK: - SwiftData Operations
    // Generic helpers that accept `any PersistentModel.Type`.
    // Swift's implicit existential opening binds the concrete type to `M`,
    // allowing use with SwiftData's generic APIs like `FetchDescriptor<M>`.

    private func performFetch<M: PersistentModel>(_: M.Type) throws -> [M] {
        try modelContext.fetch(FetchDescriptor<M>())
    }

    private func performCount<M: PersistentModel>(_: M.Type) throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<M>())
    }

    private func performDeleteAll<M: PersistentModel>(_ type: M.Type) throws {
        try modelContext.delete(model: type)
    }
}
