import SwiftUI


struct HeatIndex: View {

    let gamesPlayed: Int
    let netProfit: Double
    let sumProfitSquared: Double

    private let pillCount = 6

    private var heatScore: Int {
        guard gamesPlayed > 0 else { return 0 }

        let n = Double(gamesPlayed)
        let mean = netProfit / n
        let meanSq = sumProfitSquared / n
        let variance = meanSq - (mean * mean)
        let std = sqrt(max(variance, 0))

        guard std > 0 else { return 0 }

        let z = netProfit / (std * sqrt(n))
        let clamped = min(max(z, -3), 3)
        return Int(clamped.rounded())
    }

    private var heatLevel: HeatLevel {
        HeatLevel(rawValue: heatScore) ?? .neutral
    }

    /// Maps heat score (-3…3) to number of filled pills (0…6)
    private var filledPills: Int {
        heatScore + 3
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: heatLevel.icon)
                    .foregroundColor(heatLevel.color)
                Text("Heat Index")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(heatLevel.color)
            }

            // Pills
            ZStack {
                // Unfilled pills (background layer)
                HStack(spacing: 6) {
                    ForEach(0..<pillCount, id: \.self) { index in
                        Capsule()
                            .fill(Color(white: 0.15))
                            .frame(height: 12)
                            .overlay(
                                Capsule()
                                    .stroke(Color(white: 0.22), lineWidth: 1)
                            )
                    }
                }

                // Gradient masked by filled pill shapes
                heatLevel.gradient
                    .mask {
                        HStack(spacing: 6) {
                            ForEach(0..<pillCount, id: \.self) { index in
                                Capsule()
                                    .frame(height: 12)
                                    .opacity(index < filledPills ? 1 : 0)
                            }
                        }
                    }
                    .overlay {
                        HStack(spacing: 6) {
                            ForEach(0..<pillCount, id: \.self) { index in
                                Capsule()
                                    .stroke(
                                        index < filledPills ? heatLevel.color.opacity(0.4) : .clear,
                                        lineWidth: 1
                                    )
                                    .frame(height: 12)
                            }
                        }
                    }
            }

            // Label
            Text(heatLevel.label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(heatLevel.color.opacity(0.85))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(white: 0.18), lineWidth: 1)
        )
    }
}
