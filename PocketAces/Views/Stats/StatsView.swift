import SwiftUI
import Charts

struct StatsView: View {
    @Environment(UserStore.self) private var userStore
    @State private var vm = StatsViewModel()
    @State private var appeared = false

    // MARK: - Palette

    private let gold = Color(red: 0.85, green: 0.75, blue: 0.45)
    private let dimGold = Color(red: 0.72, green: 0.65, blue: 0.42)
    private let feltGreen = Color(red: 0.12, green: 0.42, blue: 0.28)
    private let feltDark = Color(red: 0.06, green: 0.22, blue: 0.14)
    private let accentGreen = Color(red: 0.3, green: 0.85, blue: 0.45)
    private let accentRed = Color(red: 0.95, green: 0.35, blue: 0.35)

    var body: some View {
        NavigationStack {
            scrollContent
        }
        .onAppear {
            vm.load(from: userStore)
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                appeared = true
            }
        }
        .onChange(of: userStore.userData?.gamesPlayed) {
            vm.load(from: userStore)
        }
    }

    // MARK: - Main Content

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                GamesWidgetCard(played: vm.gamesPlayed, won: vm.wins)
                    .cardEntrance(index: 1, appeared: appeared)

                HeatIndex(gamesPlayed: vm.gamesPlayed, netProfit: vm.netProfit, sumProfitSquared: vm.sumProfitSquared)
                    .cardEntrance(index: 2, appeared: appeared)
                
                extremesRow
                    .cardEntrance(index: 3, appeared: appeared)

                streakSection
                    .cardEntrance(index: 4, appeared: appeared)

                advancedMetrics
                    .cardEntrance(index: 5, appeared: appeared)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .padding(.top, 12)
        }
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
    }



    private func legendRow(color: Color, label: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.5))

            Spacer()

            Text("\(count)")
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundStyle(.white)
        }
        .frame(minWidth: 120)
    }


    // MARK: - Extremes

    private var extremesRow: some View {
        HStack(spacing: 12) {
            extremeCard(
                label: "Biggest Win",
                value: vm.biggestWin.formattedCurrency(decimals: 0, showSign: true),
                icon: "trophy.fill",
                iconColor: gold,
                valueColor: accentGreen
            )

            extremeCard(
                label: "Biggest Loss",
                value: vm.biggestLoss.formattedCurrency(decimals: 0, showSign: true),
                icon: "arrow.down.circle.fill",
                iconColor: accentRed,
                valueColor: accentRed
            )
        }
    }

    private func extremeCard(
        label: String,
        value: String,
        icon: String,
        iconColor: Color,
        valueColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(iconColor)

                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.4))
                    .tracking(0.3)
                    .textCase(.uppercase)
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(valueColor)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(gold, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Streaks

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Streaks", icon: "flame.fill")

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                streakCard(
                    label: "Current Win",
                    value: vm.currentWinStreak,
                    icon: "flame.fill",
                    isActive: vm.isOnWinStreak,
                    isRecord: vm.isAtLongestWinStreak,
                    activeColor: accentGreen
                )

                streakCard(
                    label: "Current Loss",
                    value: vm.currentLossStreak,
                    icon: "snowflake",
                    isActive: vm.isOnLossStreak,
                    isRecord: vm.isAtLongestLossStreak,
                    activeColor: accentRed
                )

                streakCard(
                    label: "Longest Win",
                    value: vm.longestWinStreak,
                    icon: "crown.fill",
                    isActive: false,
                    isRecord: false,
                    activeColor: gold
                )

                streakCard(
                    label: "Longest Loss",
                    value: vm.longestLossStreak,
                    icon: "exclamationmark.triangle.fill",
                    isActive: false,
                    isRecord: false,
                    activeColor: Color.white.opacity(0.5)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(gold, lineWidth: 1)
                )
        )
    }

    private func streakCard(
        label: String,
        value: Int,
        icon: String,
        isActive: Bool,
        isRecord: Bool,
        activeColor: Color
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(activeColor.opacity(isActive ? 0.15 : 0.06))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isActive ? activeColor : Color.white.opacity(0.25))
            }
            .overlay(alignment: .topTrailing) {
                if isRecord {
                    Circle()
                        .fill(gold)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .fill(gold.opacity(0.4))
                                .frame(width: 14, height: 14)
                        )
                        .offset(x: 2, y: -2)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.35))
                    .tracking(0.3)
                    .textCase(.uppercase)

                Text("\(value)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(isActive ? activeColor : .white)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) streak: \(value)")
    }

    // MARK: - Advanced Metrics

    private var advancedMetrics: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Advanced", icon: "function")

            VStack(spacing: 0) {
                metricRow(
                    label: "Avg Profit / Session",
                    value: vm.averageProfit.formattedCurrency(decimals: 2, showSign: true),
                    valueColor: vm.averageProfit >= 0 ? accentGreen : accentRed,
                )

                metricRow(
                    label: "ROI",
                    value: String(format: "%+.1f%%", vm.roi),
                    valueColor: vm.roi >= 0 ? accentGreen : accentRed,
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
                        .strokeBorder(gold, lineWidth: 1)
                )
        )
    }

    private func metricRow(
        label: String,
        value: String,
        valueColor: Color = .white,
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
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.white.opacity(0.5))
                .tracking(0.5)
                .textCase(.uppercase)
        }
    }
}

// MARK: - Card Entrance Animation

private struct CardEntranceModifier: ViewModifier {
    let index: Int
    let appeared: Bool

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(
                .spring(duration: 0.5, bounce: 0.15)
                    .delay(Double(index) * 0.05),
                value: appeared
            )
    }
}

extension View {
    fileprivate func cardEntrance(index: Int, appeared: Bool) -> some View {
        modifier(CardEntranceModifier(index: index, appeared: appeared))
    }
}

#Preview {
    StatsView()
        .environment(UserStore())
}
