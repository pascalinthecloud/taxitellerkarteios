import Foundation
import AuthenticationServices
import UIKit

struct TokenSet: Sendable {
    let accessToken: String
    let refreshToken: String?
    let accessTokenExpiresAt: Date
}

enum KeycloakError: Error, LocalizedError {
    case invalidIssuer
    case userCancelled
    case missingCode
    case stateMismatch
    case tokenRequest(status: Int, body: String?)
    case decode(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidIssuer:                "Konfigurationsfehler (Issuer)."
        case .userCancelled:                "Anmeldung abgebrochen."
        case .missingCode:                  "Antwort von Keycloak war unvollständig."
        case .stateMismatch:                "Sicherheitsprüfung fehlgeschlagen (state)."
        case .tokenRequest(let s, let b):   "Token-Fehler (HTTP \(s))" + (b.map { ": \($0)" } ?? "")
        case .decode(let e):                "Antwort konnte nicht gelesen werden: \(e.localizedDescription)"
        case .network(let e):               e.localizedDescription
        }
    }
}

@MainActor
final class KeycloakClient: NSObject, ASWebAuthenticationPresentationContextProviding {
    let issuer: URL
    let clientID: String
    let redirectURI: String
    let callbackScheme: String

    init(
        issuer: URL = AppEnvironment.keycloakIssuer,
        clientID: String = AppEnvironment.keycloakClientID,
        redirectURI: String = AppEnvironment.oauthRedirectURI,
        callbackScheme: String = AppEnvironment.oauthCallbackScheme
    ) {
        self.issuer = issuer
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.callbackScheme = callbackScheme
        super.init()
    }

    private var authorizeURL: URL {
        issuer.appendingPathComponent("protocol/openid-connect/auth")
    }
    private var tokenURL: URL {
        issuer.appendingPathComponent("protocol/openid-connect/token")
    }

    func signIn() async throws -> TokenSet {
        let pair = PKCE.makePair()
        let state = PKCE.randomURLSafeString(byteCount: 32)
        let nonce = PKCE.randomURLSafeString(byteCount: 32)

        var components = URLComponents(url: authorizeURL, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "openid profile email offline_access"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "nonce", value: nonce),
            URLQueryItem(name: "code_challenge", value: pair.challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
        ]
        guard let authURL = components?.url else { throw KeycloakError.invalidIssuer }

        let callbackURL = try await startWebAuthSession(authURL: authURL)

        let callbackComponents = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)
        let returnedState = callbackComponents?.queryItems?.first(where: { $0.name == "state" })?.value
        guard returnedState == state else { throw KeycloakError.stateMismatch }
        guard let code = callbackComponents?.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw KeycloakError.missingCode
        }

        return try await exchangeCode(code: code, verifier: pair.verifier)
    }

    func refresh(refreshToken: String) async throws -> TokenSet {
        try await postToken([
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientID,
        ])
    }

    private func exchangeCode(code: String, verifier: String) async throws -> TokenSet {
        try await postToken([
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientID,
            "code_verifier": verifier,
        ])
    }

    private func postToken(_ body: [String: String]) async throws -> TokenSet {
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.urlFormEncoded()

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw KeycloakError.network(error)
        }

        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            throw KeycloakError.tokenRequest(status: status, body: String(data: data, encoding: .utf8))
        }

        struct TokenResponse: Decodable {
            let accessToken: String
            let refreshToken: String?
            let expiresIn: TimeInterval
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let r = try decoder.decode(TokenResponse.self, from: data)
            return TokenSet(
                accessToken: r.accessToken,
                refreshToken: r.refreshToken,
                accessTokenExpiresAt: Date().addingTimeInterval(r.expiresIn)
            )
        } catch {
            throw KeycloakError.decode(error)
        }
    }

    private func startWebAuthSession(authURL: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<URL, Error>) in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: callbackScheme
            ) { callbackURL, error in
                if let error {
                    let nsError = error as NSError
                    if nsError.domain == ASWebAuthenticationSessionError.errorDomain,
                       nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        cont.resume(throwing: KeycloakError.userCancelled)
                    } else {
                        cont.resume(throwing: KeycloakError.network(error))
                    }
                    return
                }
                guard let callbackURL else {
                    cont.resume(throwing: KeycloakError.missingCode)
                    return
                }
                cont.resume(returning: callbackURL)
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }
    }

    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            for case let scene as UIWindowScene in UIApplication.shared.connectedScenes
                where scene.activationState == .foregroundActive {
                if let window = scene.windows.first(where: \.isKeyWindow) ?? scene.windows.first {
                    return window
                }
            }
            // Fallback: any window scene. On iOS there is always one
            // by the time we reach a sign-in flow.
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene }).first else {
                preconditionFailure("No UIWindowScene available for sign-in")
            }
            return UIWindow(windowScene: scene)
        }
    }
}

private extension Dictionary where Key == String, Value == String {
    func urlFormEncoded() -> Data {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "+&=")
        let pairs = map { key, value in
            let k = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
            let v = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
            return "\(k)=\(v)"
        }
        return Data(pairs.joined(separator: "&").utf8)
    }
}
