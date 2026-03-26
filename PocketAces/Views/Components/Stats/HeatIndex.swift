import SwiftUI


struct HeatIndex: View {

    let recentResults: [Double]

    private let pillCount = 7

    private var heatScore: Int {
        guard !recentResults.isEmpty else { return 3 }

        let avg = recentResults.reduce(0, +) / Double(recentResults.count)

        if avg < -0.6 { return 0 }
        else if avg < -0.3 { return 1 }
        else if avg < -0.1 { return 2 }
        else if avg < 0.1 { return 3 }
        else if avg < 0.4 { return 4 }
        else if avg < 0.8 { return 5 }
        else { return 6 }
    }

    private var heatLevel: HeatLevel {
        HeatLevel(rawValue: heatScore) ?? .neutral
    }

    private var filledPills: Int {
        heatScore+1
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
