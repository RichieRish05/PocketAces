import Foundation
import FirebaseFirestore

struct Player: Codable, Hashable {
    var playerId: String
    var name: String?
    var avatarName: String
    var buyIn: Double
    var cashOut: Double
    var isActive: Bool
}

struct Game: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var hostDisplayName: String
    var hostId: String
    var joinCode: String
    var joinCodeEnabled: Bool
    var playerCount: Int
    var activePlayerCount: Int
    var players: [Player]
    var playerIds: [String]
    var isActive: Bool
    var startedAt: Date
    var endedAt: Date?
    var totalPot: Double

}
