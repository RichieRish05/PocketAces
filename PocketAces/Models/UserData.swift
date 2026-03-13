import Foundation


struct UserData: Codable {
    var id: String
    var displayName: String
    var avatarName: String
    var gamesPlayed: Int
    var totalBuyIn: Double
    var totalCashOut: Double
    var netProfit: Double
    var sumProfitSquared: Double
    var wins: Int
    var itm: Int
    var biggestWin: Double
    var biggestLoss: Double
    var currentWinStreak: Int
    var currentLossStreak: Int
    var longestWinStreak: Int
    var longestLossStreak: Int
    var createdAt: Date
}
