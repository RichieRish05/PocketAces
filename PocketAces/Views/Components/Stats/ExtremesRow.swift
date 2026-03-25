import SwiftUI

struct ExtremesRow: View {

    let biggestWin: Double
    let biggestLoss: Double

    var body: some View {
        HStack(spacing: 12) {
            StatsCard(
                label: "Best Win",
                value: biggestWin.formattedCurrency(decimals: 0, showSign: true),
                icon: "rosette",
                iconColor: Theme.accentGreen,
                valueColor: Theme.accentGreen
            )

            StatsCard(
                label: "Worst Loss",
                value: biggestLoss.formattedCurrency(decimals: 0, showSign: true),
                icon: "chart.line.downtrend.xyaxis",
                iconColor: Theme.accentRed,
                valueColor: Theme.accentRed
            )
        }
    }
}
