import SwiftUI

struct PastGamesView: View {
    @Environment(GameService.self) private var gameService
    @Environment(AuthService.self) private var authService

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if gameService.pastGames.isEmpty && gameService.isLoadingPastGames {
                    ForEach(0..<3, id: \.self) { _ in
                        SkeletonGameCard()
                    }
                } else if gameService.pastGames.isEmpty {
                    emptyState
                } else {
                    ForEach(gameService.pastGames) { game in
                        NavigationLink(value: Route.gameSummary(game: game)) {
                            PastGameCardView(game: game)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if game.id == gameService.pastGames.last?.id {
                                loadMore()
                            }
                        }
                    }

                    if gameService.isLoadingPastGames {
                        ProgressView()
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .navigationTitle("Past Games")
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No past games yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Completed games will appear here.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private func loadMore() {
        guard let userId = authService.currentUserId else { return }
        Task {
            try? await gameService.fetchNextPastGamesPage(userId: userId)
        }
    }
}
