import SwiftUI

struct HomeView: View {
    @Environment(UserStore.self) private var userStore
    @Environment(GameService.self) private var gameService

    @State private var showCreateGame = false
    @State private var showJoinGame = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    profitLossSection
                    gameCarousel
                    actionButtons
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showCreateGame) {
                CreateGameView()
            }
            .sheet(isPresented: $showJoinGame) {
                JoinGameView()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome back, \(userStore.userData?.displayName ?? "Player")")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Profit/Loss
    @ViewBuilder
    private var profitLossSection: some View {
        let netProfit = userStore.userData?.netProfit ?? 0

        HStack(spacing: 6) {
            if netProfit >= 0 {
                Text("+\(netProfit, format: .currency(code: "USD").precision(.fractionLength(0)))")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.green)
            } else {
                Text("-\(netProfit, format: .currency(code: "USD").precision(.fractionLength(0)))")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.red)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Profile Button

    private var profileButton: some View {
        NavigationLink {
            ProfileView()
        } label: {
            let avatarName = userStore.userData?.avatarName ?? "avatar_01"
            Image(avatarName)
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
        }
    }

    // MARK: - Game Carousel
    @ViewBuilder
    private var gameCarousel: some View {
        let games = gameService.activeGames

        if games.isEmpty {
            emptyState
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(games) { game in
                            NavigationLink(value: game) {
                                GameCardView(game: game)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, 16)
                }
                .scrollTargetBehavior(.viewAligned)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "suit.spade.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            Text("No games yet")
                .font(.headline)

            Text("Create or join a game to get started!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(width: 280, height: 200)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 16)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showCreateGame = true
            } label: {
                HomeActionCard(
                    title: "Create Game",
                    subtitle: "Start a new poker session",
                    icon: "plus.circle.fill",
                    color: .green
                )
            }
            .buttonStyle(.plain)

            Button {
                showJoinGame = true
            } label: {
                HomeActionCard(
                    title: "Join Game",
                    subtitle: "Enter a game with a code",
                    icon: "arrow.right.circle.fill",
                    color: .blue
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }
}
