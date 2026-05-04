import SwiftUI

struct PriceBadge: View {
    let price: Decimal?
    var size: Size = .regular

    enum Size { case regular, small }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "eurosign")
                .font(.caption2.weight(.heavy))
            Text(formatted)
                .font(size == .regular ? .ttPriceTag : .ttPriceTagSmall)
                .monospacedDigit()
        }
        .foregroundStyle(.white)
        .padding(.horizontal, size == .regular ? 12 : 8)
        .padding(.vertical, size == .regular ? 6 : 4)
        .background(
            Capsule().fill(Brand.accent)
        )
    }

    private var formatted: String {
        guard let price else { return "—" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: price as NSNumber) ?? "—"
    }
}

#Preview {
    VStack(spacing: 12) {
        PriceBadge(price: 7.5)
        PriceBadge(price: 8.99, size: .small)
        PriceBadge(price: nil)
    }
    .padding()
}
