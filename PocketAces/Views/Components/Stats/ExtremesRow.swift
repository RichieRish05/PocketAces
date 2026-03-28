import SwiftUI

struct ExtremesRow: View {

    let biggestWin: Double
    let biggestLoss: Double

    var body: some View {
        HStack(spacing: 12) {
            StatsCard(
                label: "Best Win",
                value: "+\(biggestWin.formattedCurrency(decimals: 0, showSign: false))",
                icon: "rosette",
                iconColor: Theme.silver,
                valueColor: Theme.win
            )

            StatsCard(
                label: "Worst Loss",
                value: "-\(abs(biggestLoss).formattedCurrency(decimals: 0, showSign: false))",
                icon: "chart.line.downtrend.xyaxis",
                iconColor: Theme.silver,
                valueColor: Theme.loss
            )
        }
    }
}
