import Foundation

enum Endpoint {
    case restaurants
    case restaurant(id: Int)
    case votes(restaurantId: Int)
    case comments(restaurantId: Int)
    case favorites
    case favorite(restaurantId: Int)

    var path: String {
        switch self {
        case .restaurants:                  "/api/restaurants"
        case .restaurant(let id):           "/api/restaurants/\(id)"
        case .votes(let id):                "/api/votes?id=\(id)"
        case .comments(let id):             "/api/comments?id=\(id)"
        case .favorites:                    "/api/favorites"
        case .favorite(let id):             "/api/favorites/\(id)"
        }
    }

    func url(base: URL) -> URL {
        URL(string: path, relativeTo: base)!
    }
}
