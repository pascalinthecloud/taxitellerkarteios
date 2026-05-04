import Foundation
import Observation

@Observable
@MainActor
final class RestaurantStore {
    var restaurants: [Restaurant] = []
    var isLoading = false
    var loadError: String?

    private let auth: AuthStore

    init(auth: AuthStore) {
        self.auth = auth
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        let bearer = await auth.currentBearer()
        let source: any RestaurantSource = bearer.map {
            LiveRestaurantSource(client: APIClient.shared, bearer: $0)
        } ?? MockRestaurantSource()

        do {
            restaurants = try await source.fetchAll()
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    func restaurant(by id: Int) -> Restaurant? {
        restaurants.first(where: { $0.id == id })
    }
}
