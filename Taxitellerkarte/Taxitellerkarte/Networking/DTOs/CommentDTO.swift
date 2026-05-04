import Foundation

nonisolated struct CommentDTO: Decodable, Identifiable, Sendable {
    let id: Int
    let restaurantId: Int
    let content: String
    let authorName: String?
    let isPositive: Bool?
    let imageUrl: String?
    let rating: Int?
    let createdAt: Date?
}
