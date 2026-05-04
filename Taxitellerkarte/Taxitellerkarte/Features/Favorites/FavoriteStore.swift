import Foundation
import Observation

private struct FavoriteToggleBody: Encodable, Sendable {
    let restaurantId: Int
}

private struct FavoriteToggleResponse: Decodable, Sendable {
    let favorited: Bool
    let restaurantId: Int
}

@Observable
@MainActor
final class FavoriteStore {
    private(set) var favoriteIDs: Set<Int> = []

    private let auth: AuthStore
    private let client: APIClient

    init(auth: AuthStore, client: APIClient = .shared) {
        self.auth = auth
        self.client = client
    }

    func isFavorite(_ id: Int) -> Bool { favoriteIDs.contains(id) }

    func sync() async {
        guard let bearer = await auth.currentBearer() else {
            favoriteIDs = []
            return
        }
        do {
            let ids: [Int] = try await client.get(.favorites, bearer: bearer)
            favoriteIDs = Set(ids)
        } catch {
            // Keep existing local state on failure.
        }
    }

    /// Optimistic toggle: flip immediately, roll back on error.
    func toggle(_ id: Int) async {
        guard let bearer = await auth.currentBearer() else { return }

        let wasFavorite = favoriteIDs.contains(id)
        if wasFavorite {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }

        do {
            if wasFavorite {
                let _: FavoriteToggleResponse = try await client.delete(
                    .favorite(restaurantId: id),
                    bearer: bearer
                )
            } else {
                let _: FavoriteToggleResponse = try await client.postJSON(
                    .favorites,
                    body: FavoriteToggleBody(restaurantId: id),
                    bearer: bearer
                )
            }
        } catch {
            if wasFavorite {
                favoriteIDs.insert(id)
            } else {
                favoriteIDs.remove(id)
            }
        }
    }
}
