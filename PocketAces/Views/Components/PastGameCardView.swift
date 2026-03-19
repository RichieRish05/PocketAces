import SwiftUI

struct PastGameCardView: View {
    let game: Game
    @Environment(AuthService.self) private var authService

    private var suit: SuitIcon {
        .from(gameId: game.id ?? game.joinCode)
    }

    private var cardGradient: CardGradient {
        .from(gameId: game.id ?? game.joinCode)
    }

    private var formattedDate: String {
        game.startedAt.formatted(date: .abbreviated, time: .omitted)
    }

    private var formattedPot: String {
        game.totalPot.formatted(.currency(code: "USD").precision(.fractionLength(0)))
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
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.85))

                VStack(alignment: .leading, spacing: 2) {
                    Text(game.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text("\(formattedDate) · \(game.playerCount) players · \(formattedPot) pot")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

            }
            
            Divider()

            ForEach(sortedPlayers, id: \.playerId) { player in
                playerRow(player: player)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: cardGradient.colors.map { $0.opacity(0.3) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }


    private func netFormatted(_ net: Double) -> String {
        let prefix = net >= 0 ? "+" : ""
        return prefix + net.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }
    
    private func playerRow(player: Player) -> some View {
        let net = player.cashOut - player.buyIn

        return HStack {
            Text(player.name ?? "Player")
                .font(.subheadline)
                .lineLimit(1)
            
            Spacer()
            
            Text(netFormatted(net))
                .font(.subheadline.bold())
                .foregroundStyle(net >= 0 ? .green : .red)
        }
    }
    
    
}
