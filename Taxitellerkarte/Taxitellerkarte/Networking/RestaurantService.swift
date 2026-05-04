import Foundation

protocol RestaurantSource: Sendable {
    func fetchAll() async throws -> [Restaurant]
}

struct LiveRestaurantSource: RestaurantSource {
    let client: APIClient
    let bearer: String?

    func fetchAll() async throws -> [Restaurant] {
        let dtos: [RestaurantDTO] = try await client.get(.restaurants, bearer: bearer)
        return dtos.map(Restaurant.init(dto:))
    }
}

struct MockRestaurantSource: RestaurantSource {
    func fetchAll() async throws -> [Restaurant] {
        try? await Task.sleep(for: .milliseconds(250))
        return Restaurant.sampleSet
    }
}
