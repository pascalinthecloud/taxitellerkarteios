import SwiftUI

struct CuisineChip: View {
    let cuisine: Cuisine

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: cuisine.symbol)
            Text(cuisine.label)
        }
        .font(.ttCaptionStrong)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(.regularMaterial)
        )
        .overlay(
            Capsule().strokeBorder(Color.primary.opacity(0.08))
        )
    }
}

#Preview {
    HStack {
        CuisineChip(cuisine: .greek)
        CuisineChip(cuisine: .turkish)
        CuisineChip(cuisine: .imbiss)
    }
    .padding()
}
