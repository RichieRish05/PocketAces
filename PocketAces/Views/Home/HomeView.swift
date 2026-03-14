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
                    gameCarousel
                    actionButtons
                }
                .padding(.vertical, 16)
            }
            .refreshable {
                guard let userId = userStore.userData?.id else { return }
                try? await gameService.fetchGames(userId: userId)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    profileButton
                }
            }
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

            Text(Date.now.formatted(date: .long, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
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

        if gameService.isLoadingGames {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 120)
        } else if games.isEmpty {
            emptyState
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Games")
                    .font(.headline)
                    .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(games) { game in
                            NavigationLink(value: game) {
                                GameCardView(game: game)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
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
        .frame(maxWidth: .infinity, minHeight: 160)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showCreateGame = true
            } label: {
                Label("Create Game", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)

            Button {
                showJoinGame = true
            } label: {
                Label("Join Game", systemImage: "arrow.right.circle")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 16)
    }
}
