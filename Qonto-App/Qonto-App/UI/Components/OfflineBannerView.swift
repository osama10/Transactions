import SwiftUI

struct OfflineBannerView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "wifi.slash")
                .font(.caption)

            Text("No Internet")
                .font(.caption)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(Color(.systemRed))
    }
}

// MARK: - Preview

#Preview {
    OfflineBannerView()
}
