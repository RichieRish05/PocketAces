import SwiftUI

struct GameSummaryView: View {
    let game: Game

    @Environment(AuthService.self) private var authService

    // MARK: - Computed

    private var suit: SuitIcon {
        .from(gameId: game.id ?? game.joinCode)
    }

    private var currentUserId: String? {
        authService.currentUserId
    }

    private var sortedPlayers: [Player] {
        game.players.sorted { ($0.cashOut - $0.buyIn) > ($1.cashOut - $1.buyIn) }
    }

    private var formattedDate: String {
        game.startedAt.formatted(date: .abbreviated, time: .shortened)
    }

    private var currentPlayerNet: Double? {
        guard let userId = currentUserId,
              let player = game.players.first(where: { $0.playerId == userId }) else { return nil }
        return player.cashOut - player.buyIn
    }


    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                gameHeader
                statsRow
                playerSettlement
            }
            .padding(.vertical, 16)
        }
        .navigationTitle(game.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                shareButton
            }
        }
    }

    // MARK: - Game Header Card

    private var gameHeader: some View {
        VStack(spacing: 14) {
            if let net = currentPlayerNet {
                VStack(spacing: 4) {
                    Text("Your Result")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.shared.dimAccent)

                    Text(net.formattedCurrency(showSign: true))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(net >= 0 ? Theme.win : Theme.loss)
                }
            } else {
                VStack(spacing: 4) {
                    Text("Game Complete")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.shared.dimAccent)

                    Image(systemName: suit.rawValue)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Theme.shared.accent)
                }
            }

            Text(formattedDate)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(feltGreenBackground(cornerRadius: 20))
        .padding(.horizontal, 16)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(label: "Players", value: "\(game.playerCount)")
            statDivider
            statCell(label: "Host", value: game.hostDisplayName)

            if (game.totalPot > 0.0){
                statDivider
                statCell(label: "Pot Leftovers", value: game.totalPot.formattedCurrency())
            }
        }
        .padding(.vertical, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.03))
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            }
        )
        .padding(.horizontal, 16)
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
                .textCase(.uppercase)
                .tracking(0.3)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(width: 1, height: 28)
    }

    // MARK: - Player Settlement

    private var playerSettlement: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Settlement", icon: "banknote.fill")

            VStack(spacing: 0) {
                ForEach(Array(sortedPlayers.enumerated()), id: \.element.playerId) { index, player in
                    settlementRow(player: player, rank: index + 1)

                    if index < sortedPlayers.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.04))
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 4)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.03))
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                }
            )
            .padding(.horizontal, 16)
        }
    }

    private func settlementRow(player: Player, rank: Int) -> some View {
        let net = player.cashOut - player.buyIn
        let isCurrentUser = player.playerId == currentUserId
        let isWinner = net > 0
        let isLoser = net < 0

        return HStack(spacing: 12) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(rankColor(rank: rank, net: net).opacity(0.15))
                    .frame(width: 28, height: 28)

                if rank == 1 {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.shared.accent)
                } else {
                    Text("\(rank)")
                        .font(.caption2.weight(.bold).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            // Player name
            HStack(spacing: 5) {
                Text(player.name ?? "Player")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                if isCurrentUser {
                    Text("You")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Theme.shared.primaryDark)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Theme.shared.accent.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                }
            }

            Spacer()

            // Net result only
            Text(net.formattedCurrency(showSign: true))
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundStyle(isWinner ? Theme.win : isLoser ? Theme.loss : .white.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Share Button

    private var shareButton: some View {
        ShareLink(item: settlementText) {
            Image(systemName: "square.and.arrow.up")
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.shared.dimAccent)
        }
    }

    private var settlementText: String {
        var lines: [String] = []
        lines.append("\(game.name) — Game Summary")
        lines.append(formattedDate)
        lines.append("Pot: \(game.totalPot.formattedCurrency())")
        lines.append("")

        for player in sortedPlayers {
            let net = player.cashOut - player.buyIn
            let netStr = net.formattedCurrency(decimals: 2, showSign: true)
            lines.append("\(player.name ?? "Player"): \(netStr)")
        }

        lines.append("")
        lines.append("Sent from PocketAces")
        return lines.joined(separator: "\n")
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(Theme.shared.dimAccent)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))
                .tracking(0.5)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 16)
    }

    private func feltGreenBackground(cornerRadius: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Theme.shared.primary.opacity(0.6),
                    Theme.shared.primaryDark.opacity(0.8),
                    Color(red: 0.08, green: 0.30, blue: 0.22).opacity(0.7),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.mint.opacity(0.08), Color.clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 200
            )

            RadialGradient(
                colors: [Color.cyan.opacity(0.06), Color.clear],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 180
            )

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Theme.shared.accent.opacity(0.35),
                            Color.mint.opacity(0.15),
                            Theme.shared.accent.opacity(0.25),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private func rankColor(rank: Int, net: Double) -> Color {
        if rank == 1 { return Theme.shared.accent }
        if net >= 0 { return Theme.win }
        return Theme.loss
    }
}
