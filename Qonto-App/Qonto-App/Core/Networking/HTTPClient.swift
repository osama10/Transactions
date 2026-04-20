import Foundation

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

struct NetworkRequest: Sendable {
    let url: String
    let method: HTTPMethod
    let headers: [String: String]
    let queryParameters: [String: String]

    init(
        url: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        queryParameters: [String: String] = [:]
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
    }
}

protocol NetworkServicing: Sendable {
    func send<Response: Decodable & Sendable>(_ request: NetworkRequest) async throws(NetworkError) -> Response
}
