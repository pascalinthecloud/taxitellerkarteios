import Foundation

enum APIError: Error, LocalizedError {
    case http(Int)
    case unauthorized
    case htmlResponse
    case decode(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .http(let code): "HTTP \(code)"
        case .unauthorized:   "Nicht angemeldet"
        case .htmlResponse:   "Server hat eine HTML-Seite statt JSON geliefert (vermutlich Redirect zur Anmeldung). Prüfe Backend-Deployment."
        case .decode(let e):  "Antwort konnte nicht gelesen werden: \(e.localizedDescription)"
        case .network(let e): e.localizedDescription
        }
    }
}

/// Refuses to follow HTTP redirects so we surface them as explicit
/// status codes instead of silently fetching the destination. Critical
/// for spotting an early-access wall: a 307 → /earlyaccess otherwise
/// becomes "200 + HTML" via auto-redirect.
private final class NoRedirectDelegate: NSObject, URLSessionTaskDelegate, Sendable {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping @Sendable (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}

final class APIClient: Sendable {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = AppEnvironment.apiBaseURL) {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        // Don't share cookies with the rest of the system — we don't want
        // a stale earlyaccess cookie or browser sign-in to influence
        // bearer-only API calls.
        config.httpCookieStorage = nil
        config.httpShouldSetCookies = false
        config.httpCookieAcceptPolicy = .never

        self.session = URLSession(
            configuration: config,
            delegate: NoRedirectDelegate(),
            delegateQueue: nil
        )
    }

    func get<T: Decodable & Sendable>(_ endpoint: Endpoint, bearer: String? = nil) async throws -> T {
        var request = URLRequest(url: endpoint.url(base: baseURL))
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let bearer {
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        }
        return try await perform(request)
    }

    func postJSON<Body: Encodable & Sendable, T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        body: Body,
        bearer: String? = nil
    ) async throws -> T {
        var request = URLRequest(url: endpoint.url(base: baseURL))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let bearer {
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)
        return try await perform(request)
    }

    func delete<T: Decodable & Sendable>(_ endpoint: Endpoint, bearer: String? = nil) async throws -> T {
        var request = URLRequest(url: endpoint.url(base: baseURL))
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let bearer {
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        }
        return try await perform(request)
    }

    private func perform<T: Decodable & Sendable>(_ request: URLRequest) async throws -> T {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "<no url>"
        let auth = request.value(forHTTPHeaderField: "Authorization")
        let authInfo = auth.map { "yes (\($0.count) chars)" } ?? "NO"
        APIClient.log("[API] → \(method) \(url) (auth: \(authInfo))")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            APIClient.log("[API] network error: \(error)")
            throw APIError.network(error)
        }

        let http = response as? HTTPURLResponse
        let status = http?.statusCode ?? 0
        let finalURL = http?.url?.absoluteString ?? "<no url>"
        let location = http?.value(forHTTPHeaderField: "Location") ?? "—"
        APIClient.log("[API] ← \(status), \(data.count) bytes, final URL: \(finalURL), Location: \(location)")

        if status == 401 { throw APIError.unauthorized }
        guard (200..<300).contains(status) else {
            APIClient.log("[API] body: \(APIClient.preview(data, limit: 400))")
            throw APIError.http(status)
        }

        if APIClient.looksLikeHTML(data) {
            APIClient.log("[API] body looked like HTML (route handler not reached)")
            APIClient.log("[API] body: \(APIClient.preview(data, limit: 400))")
            throw APIError.htmlResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            APIClient.log("[API] decode failed for \(T.self): \(error)")
            APIClient.log("[API] body: \(APIClient.preview(data))")
            throw APIError.decode(error)
        }
    }

    private static func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }

    private static func preview(_ data: Data, limit: Int = 2000) -> String {
        let slice = data.prefix(limit)
        let text = String(data: slice, encoding: .utf8) ?? "<binary \(data.count) bytes>"
        return data.count > limit ? "\(text)…[truncated, total \(data.count) bytes]" : text
    }

    private static func looksLikeHTML(_ data: Data) -> Bool {
        let head = data.prefix(64)
        guard let text = String(data: head, encoding: .utf8) else { return false }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.hasPrefix("<!doctype html") || trimmed.hasPrefix("<html")
    }
}
