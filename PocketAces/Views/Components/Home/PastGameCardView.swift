import SwiftUI

struct PastGameCardView: View {
    @Environment(Theme.self) private var theme
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
                    .foregroundStyle(theme.accent.opacity(0.85))

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
                theme.gradient

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        theme.borderGradient,
                        lineWidth: 1
                    )
            }
        )
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }


}
