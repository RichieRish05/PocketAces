import Foundation
import FirebaseFirestore

struct ChipDenomination: Codable, Hashable {
    var label: String
    var amount: Double
}

struct Player: Codable, Hashable {
    var playerId: String
    var name: String?
    var buyIn: Double
    var cashOut: Double
    var isActive: Bool
}

struct Game: Codable, Identifiable, Hashable {
    static func == (lhs: Game, rhs: Game) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    @DocumentID var id: String?
    var name: String
    var chipDenominations: [ChipDenomination]
    var hostDisplayName: String
    var hostId: String
    var joinCode: String
    var joinCodeEnabled: Bool
    var playerCount: Int
    var players: [Player]
    var playerIds: [String]
    var isActive: Bool
    var startedAt: Date
    var endedAt: Date?
    var totalPot: Double

}
