import SwiftUI

enum Brand {
    static let accent = Color.accentColor
    static let cardShadow = Color.black.opacity(0.08)

    enum Status {
        static let verified = Color.green
        static let unverified = Color.orange
        static let rejected = Color.gray
    }
}
