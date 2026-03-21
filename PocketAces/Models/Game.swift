import Foundation
import FirebaseFirestore

struct Player: Codable, Hashable {
    var playerId: String
    var name: String?
    var avatarName: String
    var buyIn: Double
    var cashOut: Double
    var isActive: Bool

    init(playerId: String, name: String?, avatarName: String = "avatar_01", buyIn: Double, cashOut: Double, isActive: Bool) {
        self.playerId = playerId
        self.name = name
        self.avatarName = avatarName
        self.buyIn = buyIn
        self.cashOut = cashOut
        self.isActive = isActive
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        playerId = try container.decode(String.self, forKey: .playerId)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        avatarName = try container.decodeIfPresent(String.self, forKey: .avatarName) ?? "avatar_01"
        buyIn = try container.decode(Double.self, forKey: .buyIn)
        cashOut = try container.decode(Double.self, forKey: .cashOut)
        isActive = try container.decode(Bool.self, forKey: .isActive)
    }
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
