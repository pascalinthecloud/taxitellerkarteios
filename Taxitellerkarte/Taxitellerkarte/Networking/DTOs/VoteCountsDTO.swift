import Foundation

nonisolated struct VoteCountsDTO: Decodable, Sendable {
    let yesVotes: Int
    let noVotes: Int
    let avgPrice: Decimal?
}
