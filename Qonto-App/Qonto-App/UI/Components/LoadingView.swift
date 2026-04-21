import SwiftUI

struct LoadingView: View {
    var body: some View {
        ContentUnavailableView {
            ProgressView()
        } description: {
            Text("Loading transactions...")
        }
    }
}

// MARK: - Preview

#Preview {
    LoadingView()
}
