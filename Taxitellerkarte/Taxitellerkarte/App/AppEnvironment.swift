import Foundation

nonisolated enum AppEnvironment {
    static let apiBaseURL = URL(string: "https://app.taxitellerkarte.de")!

    // TODO: set this to your Keycloak issuer URL — the same value as the
    // web app's KEYCLOAK_ISSUER env var. Format:
    //   https://<keycloak-host>/realms/<realm-name>
    static let keycloakIssuer = URL(string: "https://auth.taxitellerkarte.de/realms/taxiteller")!

    static let keycloakClientID = "taxiteller-ios"
    static let oauthRedirectURI = "de.taxitellerkarte.ios://oauth/callback"
    static let oauthCallbackScheme = "de.taxitellerkarte.ios"
}
