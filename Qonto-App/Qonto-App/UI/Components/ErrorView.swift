import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Preview

#Preview {
    ErrorView(message: "Unable to load transactions. Please check your connection.") {
        print("Retry tapped")
    }
}
