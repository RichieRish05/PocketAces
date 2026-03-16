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
                    quickStatsRow
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
    
    // MARK: - Quick Stats
    
    private var quickStatsRow: some View {
        let gamesPlayed = userStore.userData?.gamesPlayed ?? 0
        let wins = userStore.userData?.wins ?? 0
        let netProfit = userStore.userData?.netProfit ?? 0
        let winRate = gamesPlayed > 0 ? Double(wins) / Double(gamesPlayed) * 100 : 0
        
        return HStack(spacing: 8) {
            StatCardView(
                icon: "dollarsign.circle.fill",
                label: "Net Profit",
                numericValue: netProfit,
                format: .currency,
                valueColor: netProfit >= 0 ? .green : .red
            )
            StatCardView(
                icon: "trophy.fill",
                label: "Win Rate",
                numericValue: winRate,
                format: .percentage,
                valueColor: .primary
            )
            StatCardView(
                icon: "suit.spade.fill",
                label: "Games",
                numericValue: Double(gamesPlayed),
                format: .integer,
                valueColor: .primary
            )
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
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.84, blue: 0.0),
                            Color(red: 0.85, green: 0.65, blue: 0.13)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("No games yet")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.88, blue: 0.4),
                            Color(red: 0.85, green: 0.65, blue: 0.13)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Create or join a game to get started!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 200)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.14, blue: 0.02), // dark gold base
                    Color(red: 0.35, green: 0.26, blue: 0.05),
                    Color(red: 0.55, green: 0.42, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    Color(red: 0.35, green: 0.26, blue: 0.05),
                    lineWidth: 1.5
                )
        )
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
