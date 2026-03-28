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
    var biggestWin: Double
    var biggestLoss: Double
    var currentWinStreak: Int
    var currentLossStreak: Int
    var longestWinStreak: Int
    var longestLossStreak: Int
    var recentResults: [Double]
    var createdAt: Date
    var gems: Int
    var themeName: String

    /// Updates all career stats from a single cash-out result.
    /// This is a pure computation with no side effects — safe to call optimistically
    /// before the Firestore write confirms.
    mutating func applyCashOut(buyIn: Double, cashOut: Double) {
        let profit = cashOut - buyIn

        gamesPlayed += 1
        totalBuyIn += buyIn
        totalCashOut += cashOut
        netProfit += profit
        sumProfitSquared += profit * profit

        if profit >= 0 {
            wins += 1
            biggestWin = max(biggestWin, profit)
            // Win resets loss streak, extends win streak
            currentLossStreak = 0
            currentWinStreak += 1
            longestWinStreak = max(longestWinStreak, currentWinStreak)
        } else if profit < 0 {
            biggestLoss = min(biggestLoss, profit)
            // Loss resets win streak, extends loss streak
            currentWinStreak = 0
            currentLossStreak += 1
            longestLossStreak = max(longestLossStreak, currentLossStreak)
        }


        // Rolling window of last 10 results (percentage profit)
        let profitPct = buyIn == 0 ? 0 : profit / buyIn
        recentResults.append(profitPct)
        if recentResults.count > 10 {
            recentResults.removeFirst(recentResults.count - 10)
        }
    }
}
