import Foundation
import CoreLocation

nonisolated struct Restaurant: Identifiable, Hashable, Sendable {
    let id: Int
    let slug: String?
    let name: String
    let cuisine: Cuisine
    let coordinate: Coordinate
    let address: String?
    let city: String?
    let postcode: String?
    let hasTaxiTeller: Bool?
    let imageURL: URL?
    let price: Decimal?
    let paymentMethod: PaymentMethod?
    let note: String?
    let avgRating: Double
    let ratingCount: Int

    struct Coordinate: Hashable, Sendable {
        let latitude: Double
        let longitude: Double

        var clLocation: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    enum PaymentMethod: String, Sendable {
        case cash, card, both
    }
}

extension Restaurant {
    init(dto: RestaurantDTO) {
        self.id = dto.id
        self.slug = dto.slug
        self.name = dto.name
        self.cuisine = Cuisine(raw: dto.cuisine)
        self.coordinate = Coordinate(latitude: dto.lat, longitude: dto.lng)
        self.address = dto.address
        self.city = dto.city
        self.postcode = dto.postcode
        self.hasTaxiTeller = dto.hasTaxiTeller
        self.imageURL = dto.imageUrl.flatMap { URL(string: $0, relativeTo: AppEnvironment.apiBaseURL) }
        self.price = dto.taxiTellerPrice
        self.paymentMethod = dto.paymentMethod.flatMap(PaymentMethod.init(rawValue:))
        self.note = dto.note
        self.avgRating = dto.avgRating ?? 0
        self.ratingCount = dto.ratingCount ?? 0
    }
}
