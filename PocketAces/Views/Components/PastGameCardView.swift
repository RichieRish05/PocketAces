import SwiftUI

struct PastGameCardView: View {
    let game: Game
    @Environment(AuthService.self) private var authService

    private var suit: SuitIcon {
        .from(gameId: game.id ?? game.joinCode)
    }

    private let feltGreen = Color(red: 0.12, green: 0.42, blue: 0.28)
    private let feltDark = Color(red: 0.06, green: 0.22, blue: 0.14)
    private let gold = Color(red: 0.85, green: 0.75, blue: 0.45)

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
                    .foregroundStyle(gold.opacity(0.85))

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
            ZStack {
                LinearGradient(
                    colors: [
                        feltGreen.opacity(0.4),
                        feltDark.opacity(0.5),
                        Color(red: 0.08, green: 0.30, blue: 0.22).opacity(0.45),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                gold.opacity(0.2),
                                Color.mint.opacity(0.1),
                                gold.opacity(0.15),
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
