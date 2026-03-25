import SwiftUI

// MARK: - Arc Shape

struct ArcShape: Shape {
    var startAngle: Double
    var endAngle: Double
    var lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2 - lineWidth / 2,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        return path
    }
}

// MARK: - Win Rate Gauge

struct WinRateGauge: View {
    let progress: Double

    private let lineWidth: CGFloat = 14
    private let startAngle: Double = 135
    private let totalSweep: Double = 270

    private var endAngle: Double { startAngle + totalSweep }
    private var progressEndAngle: Double { startAngle + totalSweep * progress }

    var body: some View {
        ZStack {
            ArcShape(startAngle: startAngle, endAngle: endAngle, lineWidth: lineWidth)
                .stroke(
                    Color(white: 0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            ArcShape(startAngle: startAngle, endAngle: progressEndAngle, lineWidth: lineWidth)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.4, blue: 0.45),
                            Color(red: 1.0, green: 0.85, blue: 0.5),
                            Color(red: 0.45, green: 0.8, blue: 0.45)
                        ]),
                        center: .center,
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(endAngle)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(Int(progress * 100))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("%")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                }
                Text("Win rate")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(white: 0.55))
            }
            .foregroundColor(.white)
        }
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let value: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.55))
            Spacer()
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Card Header

struct CardHeader: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "square.stack.3d.up.fill")
                Text("Games")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Full Card

struct GamesWidgetCard: View {
    let played: Int
    let won: Int

    private var winRate: Double {
        played > 0 ? Double(won) / Double(played) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardHeader()

            HStack(spacing: 24) {
                WinRateGauge(progress: winRate)
                    .frame(width: 140, height: 140)

                Rectangle()
                    .fill(Color(white: 0.25))
                    .frame(width: 1)
                    .padding(.vertical, 8)

                VStack(spacing: 20) {
                    StatRow(label: "Played", value: played)
                    Divider()
                        .background(Color(white: 0.25))
                    StatRow(label: "Won", value: won)
                }
            }
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



