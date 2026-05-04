import SwiftUI

struct SearchResults: View {
    let results: [Restaurant]
    let onSelect: (Restaurant) -> Void

    var body: some View {
        if results.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
                Text("Nichts gefunden")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(results.prefix(40)) { restaurant in
                        Button {
                            onSelect(restaurant)
                        } label: {
                            row(for: restaurant)
                        }
                        .buttonStyle(.plain)

                        if restaurant.id != results.prefix(40).last?.id {
                            Divider().padding(.leading, 60)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .frame(maxHeight: 360)
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func row(for restaurant: Restaurant) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Brand.accent.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: restaurant.cuisine.symbol)
                    .foregroundStyle(Brand.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(restaurant.name)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                if let secondary = secondary(for: restaurant) {
                    Text(secondary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let price = restaurant.price {
                PriceBadge(price: price, size: .small)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private func secondary(for r: Restaurant) -> String? {
        let parts = [r.address, r.city].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}
