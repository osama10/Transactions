import Foundation

enum APIEndpoint {
    private static let baseURL = "https://us-central1-qonto-staging.cloudfunctions.net"

    static func transactions(page: Int, results: Int, seed: String) -> NetworkRequest {
        NetworkRequest(
            url: "\(baseURL)/transactions",
            queryParameters: [
                "results": "\(results)",
                "page": "\(page)",
                "seed": seed
            ]
        )
    }
}
