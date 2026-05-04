import SwiftUI

struct StatusDot: View {
    enum Status { case verified, unverified, rejected }

    let status: Status

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.ttCaptionStrong)
                .foregroundStyle(.secondary)
        }
    }

    private var color: Color {
        switch status {
        case .verified:   Brand.Status.verified
        case .unverified: Brand.Status.unverified
        case .rejected:   Brand.Status.rejected
        }
    }

    private var label: String {
        switch status {
        case .verified:   "Verifiziert"
        case .unverified: "Unbestätigt"
        case .rejected:   "Kein Taxi Teller"
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        StatusDot(status: .verified)
        StatusDot(status: .unverified)
        StatusDot(status: .rejected)
    }
    .padding()
}
