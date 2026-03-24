import SwiftUI
import Charts

struct BellCurveChart: View {
    let points: [StatsViewModel.CurvePoint]
    let mean: Double
    let sigma: Double

    private let feltGreen = Color(red: 0.18, green: 0.55, blue: 0.31)
    private let gold = Color(red: 0.85, green: 0.75, blue: 0.45)
    private let dimGold = Color(red: 0.72, green: 0.65, blue: 0.42)

    @State private var revealFraction: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel

            Chart {
                // Shaded area under curve
                ForEach(visiblePoints) { point in
                    AreaMark(
                        x: .value("Profit", point.x),
                        y: .value("Density", point.y)
                    )
                    .foregroundStyle(areaGradient)
                    .interpolationMethod(.catmullRom)
                }

                // Curve line
                ForEach(visiblePoints) { point in
                    LineMark(
                        x: .value("Profit", point.x),
                        y: .value("Density", point.y)
                    )
                    .foregroundStyle(feltGreen)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .interpolationMethod(.catmullRom)
                }

                // Mean line
                RuleMark(x: .value("Mean", mean))
                    .foregroundStyle(gold)
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .annotation(position: .top, alignment: .center) {
                        Text("Avg: \(mean.formattedCurrency(decimals: 0))")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(gold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.9))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(gold.opacity(0.3), lineWidth: 0.5)
                                    )
                            )
                    }

                // +1σ line
                if sigma > 0 {
                    RuleMark(x: .value("+1σ", mean + sigma))
                        .foregroundStyle(Color.white.opacity(0.15))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 5]))

                    // -1σ line
                    RuleMark(x: .value("-1σ", mean - sigma))
                        .foregroundStyle(Color.white.opacity(0.15))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 5]))

                    // +2σ line
                    RuleMark(x: .value("+2σ", mean + 2 * sigma))
                        .foregroundStyle(Color.white.opacity(0.08))
                        .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [2, 6]))

                    // -2σ line
                    RuleMark(x: .value("-2σ", mean - 2 * sigma))
                        .foregroundStyle(Color.white.opacity(0.08))
                        .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [2, 6]))
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: xAxisValues) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(v.formattedCurrency(decimals: 0))
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundStyle(Color.white.opacity(0.35))
                        }
                    }
                    AxisGridLine()
                        .foregroundStyle(Color.white.opacity(0.05))
                }
            }
            .chartPlotStyle { plotContent in
                plotContent
                    .background(Color.white.opacity(0.02))
                    .border(Color.white.opacity(0.04), width: 0.5)
            }
            .frame(height: 200)

            // 68% annotation
            if sigma > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "chart.dots.scatter")
                        .font(.system(size: 10))
                        .foregroundStyle(feltGreen)

                    Text("68% of sessions fall between \((mean - sigma).formattedCurrency(decimals: 0)) and \((mean + sigma).formattedCurrency(decimals: 0))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.45))
                }
                .padding(.top, 2)
            }
        }
        .padding(20)
        .background(cardBackground)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                revealFraction = 1
            }
        }
    }

    // MARK: - Computed

    private var visiblePoints: [StatsViewModel.CurvePoint] {
        let count = Int(Double(points.count) * revealFraction)
        return Array(points.prefix(max(count, 2)))
    }

    private var xAxisValues: [Double] {
        guard sigma > 0 else { return [mean] }
        return [mean - 2 * sigma, mean - sigma, mean, mean + sigma, mean + 2 * sigma]
    }

    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [feltGreen.opacity(0.4), feltGreen.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var sectionLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 12))
                .foregroundStyle(dimGold)

            Text("Profit Distribution")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.white.opacity(0.5))
                .tracking(0.5)
                .textCase(.uppercase)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(0.03))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            )
    }
}

// MARK: - Placeholder for insufficient data

struct BellCurvePlaceholder: View {
    private let dimGold = Color(red: 0.72, green: 0.65, blue: 0.42)

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 12))
                    .foregroundStyle(dimGold)

                Text("Profit Distribution")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.5))
                    .tracking(0.5)
                    .textCase(.uppercase)

                Spacer()
            }

            VStack(spacing: 10) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.white.opacity(0.15))

                Text("Play 3+ games to see your distribution")
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.3))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
