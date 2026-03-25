import Foundation

@Observable
final class StatsViewModel {
    private(set) var userData: UserData?

    // MARK: - Derived Metrics

    var gamesPlayed: Int { userData?.gamesPlayed ?? 0 }
    var netProfit: Double { userData?.netProfit ?? 0 }
    var wins: Int { userData?.wins ?? 0 }
    var biggestWin: Double { userData?.biggestWin ?? 0 }
    var biggestLoss: Double { userData?.biggestLoss ?? 0 }
    var currentWinStreak: Int { userData?.currentWinStreak ?? 0 }
    var currentLossStreak: Int { userData?.currentLossStreak ?? 0 }
    var longestWinStreak: Int { userData?.longestWinStreak ?? 0 }
    var longestLossStreak: Int { userData?.longestLossStreak ?? 0 }
    var totalBuyIn: Double { userData?.totalBuyIn ?? 0 }
    var totalCashOut: Double { userData?.totalCashOut ?? 0 }
    var sumProfitSquared: Double { userData?.sumProfitSquared ?? 0 }
    var recentResults: [Double] { userData?.recentResults ?? [] }

    var winRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(wins) / Double(gamesPlayed) * 100
    }

    var averageProfit: Double {
        guard gamesPlayed > 0 else { return 0 }
        return netProfit / Double(gamesPlayed)
    }

    var roi: Double {
        guard totalBuyIn > 0 else { return 0 }
        return (netProfit / totalBuyIn) * 100
    }

    // MARK: - Load

    func load(from userStore: UserStore) {
        self.userData = userStore.userData
    }
}
