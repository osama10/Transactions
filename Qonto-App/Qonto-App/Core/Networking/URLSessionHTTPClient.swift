import Foundation

struct URLSessionHTTPClient: NetworkServicing {
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func send<Response: Decodable & Sendable>(_ request: NetworkRequest) async throws(NetworkError) -> Response {
        let urlRequest = try makeURLRequest(request)
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: urlRequest)
        } catch {
            throw .requestFailed(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw .unacceptableStatusCode(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw .decodingFailed(error)
        }
    }

    private func makeURLRequest(_ request: NetworkRequest) throws(NetworkError) -> URLRequest {
        guard var components = URLComponents(string: request.url) else {
            throw .invalidURL
        }

        if !request.queryParameters.isEmpty {
            components.queryItems = request.queryParameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }

        guard let url = components.url else {
            throw .invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        request.headers.forEach { field, value in
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }
        return urlRequest
    }
}
