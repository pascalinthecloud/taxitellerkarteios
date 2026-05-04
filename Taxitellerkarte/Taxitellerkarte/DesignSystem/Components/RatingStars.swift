import SwiftUI

struct RatingStars: View {
    let rating: Double
    let count: Int
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: symbol(for: index))
                        .foregroundStyle(Brand.accent)
                }
            }
            .font(compact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))

            if !compact, count > 0 {
                Text("\(formattedRating) · \(count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }

    private func symbol(for index: Int) -> String {
        let value = rating - Double(index)
        if value >= 0.75 { return "star.fill" }
        if value >= 0.25 { return "star.leadinghalf.filled" }
        return "star"
    }

    private var formattedRating: String {
        String(format: "%.1f", rating)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        RatingStars(rating: 4.3, count: 27)
        RatingStars(rating: 3.5, count: 9)
        RatingStars(rating: 0, count: 0)
        RatingStars(rating: 5, count: 1, compact: true)
    }
    .padding()
}
