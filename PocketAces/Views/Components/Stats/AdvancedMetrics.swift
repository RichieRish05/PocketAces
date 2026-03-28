import SwiftUI

struct AdvancedMetrics: View {

    let averageProfit: Double
    let roi: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Advanced", icon: "bird.fill")

            VStack(spacing: 0) {
                metricRow(
                    label: "Avg Profit / Session",
                    value: averageProfit.formattedCurrency(decimals: 2, showSign: true),
                    valueColor: averageProfit >= 0 ? Theme.win : Theme.loss
                )

                metricRow(
                    label: "ROI",
                    value: String(format: "%+.1f%%", roi),
                    valueColor: roi >= 0 ? Theme.win : Theme.loss
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
                    .font(.system(size: 15))
                    .foregroundStyle(Color.white.opacity(0.5))

                Spacer()

                Text(value)
                    .font(.system(size: 15, weight: .bold).monospacedDigit())
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

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}
