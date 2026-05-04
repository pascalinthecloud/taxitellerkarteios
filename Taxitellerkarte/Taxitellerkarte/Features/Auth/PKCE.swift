import CryptoKit
import Foundation

nonisolated enum PKCE {
    struct Pair: Sendable {
        let verifier: String
        let challenge: String
    }

    /// Generates a fresh code verifier and S256 challenge pair.
    static func makePair() -> Pair {
        let verifier = randomURLSafeString(byteCount: 64)
        let challenge = sha256URLSafe(verifier)
        return Pair(verifier: verifier, challenge: challenge)
    }

    static func randomURLSafeString(byteCount: Int) -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        _ = SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes)
        return Data(bytes).base64URLEncodedString()
    }

    private static func sha256URLSafe(_ input: String) -> String {
        let digest = SHA256.hash(data: Data(input.utf8))
        return Data(digest).base64URLEncodedString()
    }
}

nonisolated extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
