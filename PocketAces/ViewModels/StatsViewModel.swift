import Foundation

@Observable
final class StatsViewModel {
    private(set) var userData: UserData?

    // MARK: - Derived Metrics

    var gamesPlayed: Int { userData?.gamesPlayed ?? 0 }
    var netProfit: Double { userData?.netProfit ?? 0 }
    var wins: Int { userData?.wins ?? 0 }
    var itm: Int { userData?.itm ?? 0 }
    var biggestWin: Double { userData?.biggestWin ?? 0 }
    var biggestLoss: Double { userData?.biggestLoss ?? 0 }
    var currentWinStreak: Int { userData?.currentWinStreak ?? 0 }
    var currentLossStreak: Int { userData?.currentLossStreak ?? 0 }
    var longestWinStreak: Int { userData?.longestWinStreak ?? 0 }
    var longestLossStreak: Int { userData?.longestLossStreak ?? 0 }
    var totalBuyIn: Double { userData?.totalBuyIn ?? 0 }
    var totalCashOut: Double { userData?.totalCashOut ?? 0 }

    var winRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(wins) / Double(gamesPlayed) * 100
    }

    var itmRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(itm) / Double(gamesPlayed) * 100
    }

    var averageProfit: Double {
        guard gamesPlayed > 0 else { return 0 }
        return netProfit / Double(gamesPlayed)
    }

    var roi: Double {
        guard totalBuyIn > 0 else { return 0 }
        return (netProfit / totalBuyIn) * 100
    }

    // MARK: - Bell Curve Stats

    var mean: Double {
        guard gamesPlayed > 0 else { return 0 }
        return netProfit / Double(gamesPlayed)
    }

    var variance: Double {
        guard gamesPlayed > 0 else { return 0 }
        let sumProfitSquared = userData?.sumProfitSquared ?? 0
        return (sumProfitSquared / Double(gamesPlayed)) - (mean * mean)
    }

    var standardDeviation: Double {
        let v = variance
        guard v > 0 else { return 0 }
        return sqrt(v)
    }

    var hasSufficientData: Bool {
        gamesPlayed >= 3
    }

    var hasValidDistribution: Bool {
        hasSufficientData && standardDeviation > 0
    }

    // MARK: - Bell Curve Points

    struct CurvePoint: Identifiable {
        let id = UUID()
        let x: Double
        let y: Double
    }

    func bellCurvePoints(count: Int = 200) -> [CurvePoint] {
        guard hasValidDistribution else { return [] }

        let mu = mean
        let sigma = standardDeviation
        let minX = mu - 3.5 * sigma
        let maxX = mu + 3.5 * sigma
        let step = (maxX - minX) / Double(count - 1)

        return (0..<count).map { i in
            let x = minX + Double(i) * step
            let exponent = -0.5 * pow((x - mu) / sigma, 2)
            let y = (1.0 / (sigma * sqrt(2 * .pi))) * exp(exponent)
            return CurvePoint(x: x, y: y)
        }
    }

    // MARK: - Streak State

    var isOnWinStreak: Bool { currentWinStreak > 0 }
    var isOnLossStreak: Bool { currentLossStreak > 0 }
    var isAtLongestWinStreak: Bool { currentWinStreak > 0 && currentWinStreak == longestWinStreak }
    var isAtLongestLossStreak: Bool { currentLossStreak > 0 && currentLossStreak == longestLossStreak }

    // MARK: - Load

    func load(from userStore: UserStore) {
        self.userData = userStore.userData
    }
}
