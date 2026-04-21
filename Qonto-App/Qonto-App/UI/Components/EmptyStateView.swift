import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No transactions yet", systemImage: "tray")
        } description: {
            Text("Your transactions will appear here")
        }
    }
}

// MARK: - Preview

#Preview {
    EmptyStateView()
}
