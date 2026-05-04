import SwiftUI

struct RestaurantSheet: View {
    let restaurant: Restaurant
    @Environment(\.openURL) private var openURL
    @Environment(AuthStore.self) private var auth
    @Environment(FavoriteStore.self) private var favorites

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                header
                stats
                if let address = formattedAddress {
                    addressSection(address)
                }
                if let note = restaurant.note, !note.isEmpty {
                    noteSection(note)
                }
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var hero: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Brand.accent.opacity(0.20), Brand.accent.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 140)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 56, weight: .light))
                        .foregroundStyle(Brand.accent.opacity(0.55))
                )

            HStack(alignment: .top) {
                if let price = restaurant.price {
                    PriceBadge(price: price)
                        .shadow(color: Brand.cardShadow, radius: 6, y: 2)
                }
                Spacer()
                if auth.state == .signedIn {
                    favoriteButton
                }
            }
            .padding(12)
        }
    }

    @ViewBuilder
    private var favoriteButton: some View {
        let isFavorite = favorites.isFavorite(restaurant.id)
        Button {
            Task { await favorites.toggle(restaurant.id) }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.headline.weight(.semibold))
                .foregroundStyle(isFavorite ? Brand.accent : .primary)
                .frame(width: 40, height: 40)
                .background(.regularMaterial, in: Circle())
                .overlay(Circle().strokeBorder(Color.primary.opacity(0.06)))
                .shadow(color: Brand.cardShadow, radius: 6, y: 2)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: isFavorite)
    }

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(restaurant.name)
                .font(.ttDisplayLarge)
                .lineLimit(2)

            HStack(spacing: 8) {
                CuisineChip(cuisine: restaurant.cuisine)
                StatusDot(status: statusFor(restaurant.hasTaxiTeller))
            }
        }
    }

    @ViewBuilder
    private var stats: some View {
        HStack(spacing: 12) {
            if restaurant.ratingCount > 0 {
                RatingStars(rating: restaurant.avgRating, count: restaurant.ratingCount)
            } else {
                Text("Noch keine Bewertungen")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func addressSection(_ address: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Adresse")
                .font(.ttCaptionStrong)
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: 12) {
                Text(address)
                    .font(.body)
                Spacer()
                Button {
                    openInAppleMaps()
                } label: {
                    Label("Route", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(Brand.accent)
                .controlSize(.regular)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
        )
    }

    @ViewBuilder
    private func noteSection(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hinweis")
                .font(.ttCaptionStrong)
                .foregroundStyle(.secondary)
            Text(note)
                .font(.body)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.secondary.opacity(0.06))
        )
    }

    private var formattedAddress: String? {
        let parts = [restaurant.address, [restaurant.postcode, restaurant.city].compactMap { $0 }.joined(separator: " ")]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    private func statusFor(_ value: Bool?) -> StatusDot.Status {
        switch value {
        case .some(true):  .verified
        case .some(false): .rejected
        case .none:        .unverified
        }
    }

    private func openInAppleMaps() {
        let coord = restaurant.coordinate
        guard let url = URL(string: "http://maps.apple.com/?daddr=\(coord.latitude),\(coord.longitude)&dirflg=d") else { return }
        openURL(url)
    }
}

#Preview {
    RestaurantSheet(restaurant: .sampleBerlin)
        .padding(.top, 24)
}
