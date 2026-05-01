import Foundation

enum NetworkError: Error, Sendable, LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(any Error)
    case unacceptableStatusCode(Int)
    case decodingFailed(any Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Request failed because the URL is invalid."
        case .invalidResponse:
            "The server returned an invalid response."
        case .requestFailed(let error):
            "The network request failed: \(error.localizedDescription)"
        case .unacceptableStatusCode(let statusCode):
            "The server returned an unsuccessful status code: \(statusCode)."
        case .decodingFailed(let error):
            "The response could not be decoded: \(error.localizedDescription)"
        }
    }
}
