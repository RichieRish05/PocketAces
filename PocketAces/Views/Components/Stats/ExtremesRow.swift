import SwiftUI

struct ExtremesRow: View {

    let biggestWin: Double
    let biggestLoss: Double

    private let accentGreen = Color(red: 0.3, green: 0.85, blue: 0.45)
    private let accentRed = Color(red: 0.95, green: 0.35, blue: 0.35)

    var body: some View {
        HStack(spacing: 12) {
            StatsCard(
                label: "Biggest Win",
                value: biggestWin.formattedCurrency(decimals: 0, showSign: true),
                icon: "arrow.up.circle.fill",
                iconColor: accentGreen,
                valueColor: accentGreen
            )

            StatsCard(
                label: "Biggest Loss",
                value: biggestLoss.formattedCurrency(decimals: 0, showSign: true),
                icon: "arrow.down.circle.fill",
                iconColor: accentRed,
                valueColor: accentRed
            )
        }
    }
}
