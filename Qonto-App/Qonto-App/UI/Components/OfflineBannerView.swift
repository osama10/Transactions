import SwiftUI

struct OfflineBannerView: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")

            Text("No Internet")
                .font(.subheadline)
        }
        .foregroundStyle(.secondary)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.red.opacity(0.15), in: .rect(cornerRadius: 8))
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    OfflineBannerView()
}
