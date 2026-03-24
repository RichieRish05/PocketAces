import SwiftUI

struct AdvancedMetrics: View {

    let averageProfit: Double
    let roi: Double

    // MARK: - Palette

    private let gold = Color(red: 0.85, green: 0.75, blue: 0.45)
    private let dimGold = Color(red: 0.72, green: 0.65, blue: 0.42)
    private let accentGreen = Color(red: 0.3, green: 0.85, blue: 0.45)
    private let accentRed = Color(red: 0.95, green: 0.35, blue: 0.35)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Advanced", icon: "function")

            VStack(spacing: 0) {
                metricRow(
                    label: "Avg Profit / Session",
                    value: averageProfit.formattedCurrency(decimals: 2, showSign: true),
                    valueColor: averageProfit >= 0 ? accentGreen : accentRed
                )

                metricRow(
                    label: "ROI",
                    value: String(format: "%+.1f%%", roi),
                    valueColor: roi >= 0 ? accentGreen : accentRed
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.clear)
                        .stroke(Color(white: 0.18), lineWidth: 1)
                )
        )
    }

    // MARK: - Metric Row

    private func metricRow(
        label: String,
        value: String,
        valueColor: Color = .white
    ) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.5))

                Spacer()

                Text(value)
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(valueColor)
            }
            .padding(.vertical, 12)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(dimGold)

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}
