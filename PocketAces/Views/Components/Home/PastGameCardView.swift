import SwiftUI

struct PastGameCardView: View {
    let game: Game
    @Environment(AuthService.self) private var authService

    private var suit: SuitIcon {
        .from(gameId: game.id ?? game.joinCode)
    }

    private var formattedDate: String {
        game.startedAt.formatted(date: .abbreviated, time: .omitted)
    }


    private var playerNet: Double? {
        guard let userId = authService.currentUserId,
              let player = game.players.first(where: { $0.playerId == userId }) else { return nil }
        return player.cashOut - player.buyIn
    }

    private var sortedPlayers: [Player] {
        game.players.sorted { ($0.cashOut - $0.buyIn) > ($1.cashOut - $1.buyIn) }
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: suit.rawValue)
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.gold.opacity(0.85))

                VStack(alignment: .leading, spacing: 2) {
                    Text(game.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text("\(formattedDate) · \(game.playerCount) players")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()

            }

        }
        .padding(16)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Theme.feltGreen.opacity(0.4),
                        Theme.feltDark.opacity(0.5),
                        Color(red: 0.08, green: 0.30, blue: 0.22).opacity(0.45),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Theme.gold.opacity(0.2),
                                Color.mint.opacity(0.1),
                                Theme.gold.opacity(0.15),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }


}
