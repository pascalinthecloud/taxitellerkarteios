import Foundation

nonisolated struct RestaurantDTO: Decodable, Identifiable, Sendable {
    let id: Int
    let slug: String?
    let osmId: Int64?
    let name: String
    let cuisine: String?
    let lng: Double
    let lat: Double
    let address: String?
    let city: String?
    let postcode: String?
    let openingHours: String?
    let hasTaxiTeller: Bool?
    let imageUrl: String?
    let taxiTellerPrice: Decimal?
    let paymentMethod: String?
    let note: String?
    let avgRating: Double?
    let ratingCount: Int?

    private enum CodingKeys: String, CodingKey {
        case id, slug, osmId, name, cuisine, lng, lat
        case address, city, postcode, openingHours
        case hasTaxiTeller, imageUrl, taxiTellerPrice
        case paymentMethod, note, avgRating, ratingCount
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(Int.self, forKey: .id)
        self.slug = try c.decodeIfPresent(String.self, forKey: .slug)
        self.osmId = try c.decodeFlexibleInt64(forKey: .osmId)
        self.name = try c.decode(String.self, forKey: .name)
        self.cuisine = try c.decodeIfPresent(String.self, forKey: .cuisine)
        self.lng = try c.decode(Double.self, forKey: .lng)
        self.lat = try c.decode(Double.self, forKey: .lat)
        self.address = try c.decodeIfPresent(String.self, forKey: .address)
        self.city = try c.decodeIfPresent(String.self, forKey: .city)
        self.postcode = try c.decodeIfPresent(String.self, forKey: .postcode)
        self.openingHours = try c.decodeIfPresent(String.self, forKey: .openingHours)
        self.hasTaxiTeller = try c.decodeIfPresent(Bool.self, forKey: .hasTaxiTeller)
        self.imageUrl = try c.decodeIfPresent(String.self, forKey: .imageUrl)
        self.taxiTellerPrice = try c.decodeFlexibleDecimal(forKey: .taxiTellerPrice)
        self.paymentMethod = try c.decodeIfPresent(String.self, forKey: .paymentMethod)
        self.note = try c.decodeIfPresent(String.self, forKey: .note)
        self.avgRating = try c.decodeFlexibleDouble(forKey: .avgRating)
        self.ratingCount = try c.decodeFlexibleInt(forKey: .ratingCount)
    }
}
