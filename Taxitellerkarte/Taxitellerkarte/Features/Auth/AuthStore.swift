import Foundation
import Observation

@Observable
@MainActor
final class AuthStore {
    enum State: Equatable {
        case signedOut
        case authenticating
        case signedIn
        case error(String)
    }

    private(set) var state: State = .signedOut
    private(set) var bearer: String?

    private let client: KeycloakClient

    init() {
        self.client = KeycloakClient()
        restore()
    }

    init(client: KeycloakClient) {
        self.client = client
        restore()
    }

    private func restore() {
        guard let access = KeychainStore.read(.accessToken),
              let expiry = readExpiry()
        else {
            state = .signedOut
            return
        }
        if expiry > Date().addingTimeInterval(30) {
            bearer = access
            state = .signedIn
        } else if let refreshToken = KeychainStore.read(.refreshToken) {
            Task { await refresh(using: refreshToken) }
        } else {
            state = .signedOut
        }
    }

    func signIn() async {
        state = .authenticating
        do {
            let tokens = try await client.signIn()
            persist(tokens)
            bearer = tokens.accessToken
            state = .signedIn
        } catch KeycloakError.userCancelled {
            state = .signedOut
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func signOut() {
        KeychainStore.deleteAll()
        bearer = nil
        state = .signedOut
    }

    /// Returns a non-expired bearer token, refreshing if needed.
    /// Returns nil if the user is signed out.
    func currentBearer() async -> String? {
        guard let access = KeychainStore.read(.accessToken),
              let expiry = readExpiry()
        else { return nil }

        if expiry > Date().addingTimeInterval(30) {
            return access
        }
        guard let refreshToken = KeychainStore.read(.refreshToken) else { return nil }
        await refresh(using: refreshToken)
        return bearer
    }

    private func refresh(using refreshToken: String) async {
        do {
            let tokens = try await client.refresh(refreshToken: refreshToken)
            persist(tokens)
            bearer = tokens.accessToken
            state = .signedIn
        } catch {
            KeychainStore.deleteAll()
            bearer = nil
            state = .signedOut
        }
    }

    private func persist(_ tokens: TokenSet) {
        KeychainStore.save(tokens.accessToken, for: .accessToken)
        if let refreshToken = tokens.refreshToken {
            KeychainStore.save(refreshToken, for: .refreshToken)
        }
        KeychainStore.save(
            String(tokens.accessTokenExpiresAt.timeIntervalSince1970),
            for: .accessTokenExpiry
        )
    }

    private func readExpiry() -> Date? {
        guard let s = KeychainStore.read(.accessTokenExpiry),
              let interval = TimeInterval(s) else { return nil }
        return Date(timeIntervalSince1970: interval)
    }
}
