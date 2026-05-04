import MapKit

nonisolated final class RestaurantAnnotation: NSObject, MKAnnotation {
    let restaurant: Restaurant

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
    }

    var coordinate: CLLocationCoordinate2D { restaurant.coordinate.clLocation }
    var title: String? { restaurant.name }
    var subtitle: String? { restaurant.address }
}
