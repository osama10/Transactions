import SwiftData

enum PersistenceController {

    /// Creates a `ModelContainer` configured for the given model types.
    /// - Parameters:
    ///   - modelTypes: The persistent model types to include in the container's schema.
    ///   - inMemory: When `true`, the container uses in-memory storage (useful for testing and previews).
    /// - Returns: A configured `ModelContainer`.
    @MainActor
    static func makeContainer(
        for modelTypes: [any PersistentModel.Type],
        inMemory: Bool = false
    ) throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        let schema = Schema(modelTypes)
        return try ModelContainer(for: schema, configurations: configuration)
    }
}
