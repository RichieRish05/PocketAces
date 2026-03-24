import SwiftUI

struct ExtremesRow: View {

    let biggestWin: Double
    let biggestLoss: Double

    var body: some View {
        HStack(spacing: 12) {
            StatsCard(
                label: "Biggest Win",
                value: biggestWin.formattedCurrency(decimals: 0, showSign: true),
                icon: "arrow.up.circle.fill",
                iconColor: Theme.accentGreen,
                valueColor: Theme.accentGreen
            )

            StatsCard(
                label: "Biggest Loss",
                value: biggestLoss.formattedCurrency(decimals: 0, showSign: true),
                icon: "arrow.down.circle.fill",
                iconColor: Theme.accentRed,
                valueColor: Theme.accentRed
            )
        }
    }
}
