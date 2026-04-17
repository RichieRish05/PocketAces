import SwiftUI

struct HomeView: View {
    @Environment(UserStore.self) private var userStore
    @Environment(GameService.self) private var gameService
    @Environment(AuthService.self) private var authService

    @State private var showCreateGame = false
    @State private var showJoinGame = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    activeGamesSection
                    actionRow
                    recentGamesSection
                }
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCreateGame) {
                CreateGameView()
            }
            .sheet(isPresented: $showJoinGame) {
                JoinGameView()
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .gameDetail(let gameId):
                    GameDetailView(gameId: gameId)
                case .gameSummary(let game):
                    GameSummaryView(game: game)
                case .pastGames:
                    PastGamesView()
                }
            }
        }
    }


    // MARK: - Header

    private var headerSection: some View {
        netProfitCard
            .padding(.horizontal, 20)
            .padding(.top, 12)
    }

    private var netProfitCard: some View {
        let netProfit = userStore.userData?.netProfit ?? 0
        let gamesPlayed = userStore.userData?.gamesPlayed ?? 0
        let wins = userStore.userData?.wins ?? 0
        let winRate = gamesPlayed > 0 ? Double(wins) / Double(gamesPlayed) * 100 : 0
        let isPositive = netProfit >= 0
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Net Profit")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.dimAccent)

                Spacer()

            }

            Text(netProfit.formattedCurrency(decimals: 2))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.top, -8)

            HStack(spacing: 6) {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isPositive ? Theme.win : Theme.loss)

                Text("\(gamesPlayed) games · \(Int(winRate))% win rate")
                    .font(.system(size: 12))
                    .foregroundStyle(isPositive ? Theme.win : Theme.loss)
            }
        }
    }

    // MARK: - Active Games

    @ViewBuilder
    private var activeGamesSection: some View {
        let games = gameService.activeGames

        VStack(alignment: .leading, spacing: 14) {
            if games.isEmpty {
                emptyActiveState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(games) { game in
                            NavigationLink(value: Route.gameDetail(gameId: game.id ?? "")) {
                                GameCardView(game: game, peekNext: games.count > 1)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, 20)
                }
                .scrollTargetBehavior(.viewAligned)
            }
        }
    }

    private var emptyActiveState: some View {
        EmptyTableCard()
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
    }

    // MARK: - Action Row

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button { showCreateGame = true } label: {
                Text("Host Game")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            Button { showJoinGame = true } label: {
                Text("Join Game")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Recent Games

    @ViewBuilder
    private var recentGamesSection: some View {
        let pastGames = Array(gameService.pastGames.prefix(3))

        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeader(title: "Recent Games", icon: "clock.fill", iconColor: Theme.dimAccent)

                Spacer()

                if !gameService.pastGames.isEmpty {
                    NavigationLink(value: Route.pastGames) {
                        Text("View All")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.dimAccent)
                    }
                    .padding(.trailing, 20)
                }
            }

            if pastGames.isEmpty && gameService.isLoadingPastGames {
                VStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        recentGameSkeleton
                    }
                }
                .padding(.horizontal, 20)
            } else if pastGames.isEmpty {
                emptyRecentState
            } else {
                VStack(spacing: 2) {
                    ForEach(pastGames) { game in
                        recentGameRow(game: game)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }
        }
    }

    private func recentGameRow(game: Game) -> some View {
        let suit = SuitIcon.from(gameId: game.id ?? game.joinCode)
        let net = playerNet(for: game)

        return NavigationLink(value: Route.gameSummary(game: game)) {
            HStack(spacing: 14) {
                // Suit icon with felt-green dot
                ZStack {
                    Circle()
                        .fill(Theme.gradient)
                        .frame(width: 36, height: 36)

                    Image(systemName: suit.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(game.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text("\(game.startedAt.timeAgoDisplay()) · \(game.playerCount) players")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                }

                Spacer()

                if let net {
                    Text(net.formattedCurrency(showSign: true))
                        .font(.system(size: 15, weight: .bold).monospacedDigit())
                        .foregroundStyle(net >= 0 ? Theme.win : Theme.loss)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.2))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var recentGameSkeleton: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 100, height: 12)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 70, height: 10)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .redacted(reason: .placeholder)
    }

    private var emptyRecentState: some View {
        return HStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 20))
                .foregroundStyle(.white.opacity(0.3))

            Text("Completed games will appear here")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String, iconColor: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(iconColor)

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
                .tracking(0.5)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 20)
    }

    private func playerNet(for game: Game) -> Double? {
        guard let userId = authService.currentUserId,
              let player = game.players.first(where: { $0.playerId == userId }) else { return nil }
        return player.cashOut - player.buyIn
    }

}

