import SwiftUI

struct StatsView: View {
    @Environment(UserStore.self) private var userStore
    @State private var vm = StatsViewModel()
    @State private var appeared = false

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

                HeatIndex(recentResults: vm.recentResults)
                    .cardEntrance(index: 2, appeared: appeared)
                
                ExtremesRow(biggestWin: vm.biggestWin, biggestLoss: vm.biggestLoss)
                    .cardEntrance(index: 3, appeared: appeared)

                StreakSection(
                    currentWinStreak: vm.currentWinStreak,
                    currentLossStreak: vm.currentLossStreak,
                    longestWinStreak: vm.longestWinStreak,
                    longestLossStreak: vm.longestLossStreak,
                )
                .cardEntrance(index: 4, appeared: appeared)

                AdvancedMetrics(averageProfit: vm.averageProfit, roi: vm.roi)
                    .cardEntrance(index: 5, appeared: appeared)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .padding(.top, 12)
        }
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
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
