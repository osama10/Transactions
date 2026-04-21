import SwiftData
import SwiftUI

@main
struct Qonto_AppApp: App {

    @State private var diContainer = DIContainer()

    var body: some Scene {
        WindowGroup {
            TransactionListView(viewModel: diContainer.viewModel, networkMonitor: diContainer.networkMonitor)
        }
        .modelContainer(diContainer.modelContainer)
    }
}
