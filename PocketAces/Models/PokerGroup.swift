import Foundation
import FirebaseFirestore

struct PokerGroup: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var createdBy: String           // userId of creator
    var members: [PokerGroupMember] // max 25
    var memberIds: [String]         // for Firestore array-contains queries
    var gameIds: [String]           // all games played by this group
    var createdAt: Date
    var isActive: Bool
    var joinCode: String
}

struct PokerGroupMember: Codable, Hashable {
    var userId: String
    var displayName: String
    var avatarName: String
    var joinedAt: Date
    // Stats
    var totalBuyIn: Double
    var totalCashOut: Double
    var gamesPlayed: Int
    var wins: Int
    var totalProfit: Double {
        totalCashOut - totalBuyIn
    }
}
