import SwiftUI
import MapKit

struct MapView: View {
    @Environment(AuthStore.self) private var auth
    @Environment(RestaurantStore.self) private var store
    @Environment(FavoriteStore.self) private var favorites

    @State private var selected: Restaurant?
    @State private var query: String = ""
    @State private var location = LocationManager()
    @State private var recenter: ClusteredMapView.RecenterRequest?
    @FocusState private var searchFocused: Bool

    private let cityZoomSpan = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    private let restaurantZoomSpan = MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)

    var body: some View {
        ZStack(alignment: .top) {
            ClusteredMapView(
                restaurants: store.restaurants,
                selected: $selected,
                recenter: recenter
            )
            .ignoresSafeArea()
            .onTapGesture {
                if searchFocused {
                    searchFocused = false
                }
            }

            VStack(spacing: 8) {
                SearchBar(query: $query, focused: $searchFocused)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if shouldShowResults {
                    SearchResults(results: filteredResults) { restaurant in
                        select(restaurant, zoom: restaurantZoomSpan)
                    }
                }
            }

            if let error = store.loadError {
                ErrorPill(message: error)
                    .padding(.top, 70)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    LocateMeButton {
                        location.requestOnce()
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .task(id: auth.state) {
            await store.load()
            await favorites.sync()
        }
        .onChange(of: location.lastLocation) { _, new in
            guard let new else { return }
            recenter = .init(
                id: UUID(),
                coordinate: new.clCoordinate,
                span: cityZoomSpan
            )
        }
        .alert("Standortzugriff erlauben", isPresented: Bindable(location).didDeny) {
            Button("OK") {}
        } message: {
            Text("Aktiviere den Standortzugriff in den Einstellungen, damit Spots in deiner Nähe angezeigt werden.")
        }
        .sheet(item: $selected) { restaurant in
            RestaurantSheet(restaurant: restaurant)
                .presentationDetents([.fraction(0.40), .medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationDragIndicator(.visible)
        }
    }

    private func select(_ restaurant: Restaurant, zoom span: MKCoordinateSpan) {
        searchFocused = false
        query = ""
        recenter = .init(
            id: UUID(),
            coordinate: restaurant.coordinate.clLocation,
            span: span
        )
        selected = restaurant
    }

    private var shouldShowResults: Bool {
        searchFocused && !trimmedQuery.isEmpty
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var filteredResults: [Restaurant] {
        let needle = trimmedQuery.lowercased()
        guard !needle.isEmpty else { return [] }
        return store.restaurants
            .filter { restaurant in
                restaurant.name.lowercased().contains(needle)
                || (restaurant.city?.lowercased().contains(needle) ?? false)
                || (restaurant.address?.lowercased().contains(needle) ?? false)
            }
            .sorted { lhs, rhs in
                let lhsStarts = lhs.name.lowercased().hasPrefix(needle)
                let rhsStarts = rhs.name.lowercased().hasPrefix(needle)
                if lhsStarts != rhsStarts { return lhsStarts }
                return lhs.name < rhs.name
            }
    }
}

private struct LocateMeButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "location.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Brand.accent)
                .frame(width: 48, height: 48)
                .background(.regularMaterial, in: Circle())
                .overlay(Circle().strokeBorder(Color.primary.opacity(0.06)))
                .shadow(color: Brand.cardShadow, radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct ErrorPill: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .lineLimit(2)
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Capsule().fill(.red))
        .padding(.horizontal, 16)
    }
}
