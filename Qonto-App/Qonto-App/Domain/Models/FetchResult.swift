import Foundation

/// Distinguishes between fresh remote data and offline cached data.
/// Allows the presentation layer to show appropriate UI (e.g. offline banner).
enum FetchResult: Sendable {
    case fresh([Transaction])
    case cached([Transaction])

    var transactions: [Transaction] {
        switch self {
        case .fresh(let transactions), .cached(let transactions):
            return transactions
        }
    }

    var isCached: Bool {
        if case .cached = self { return true }
        return false
    }
}
