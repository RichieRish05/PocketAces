import SwiftUI

struct GameCardView: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(game.hostDisplayName + "'s Game")
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                StatusBadge(isActive: game.isActive)
            }

            HStack(spacing: 16) {
                Label("\(game.playerCount) players", systemImage: "person.2.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label(game.startedAt.timeAgoDisplay(), systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("$\(game.totalPot, specifier: "%.0f") pot", systemImage: "dollarsign.circle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(game.joinCode)
                    .font(.caption)
                    .monospaced()
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .frame(width: 280)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
}

private struct StatusBadge: View {
    let isActive: Bool

    var body: some View {
        Text(isActive ? "In Progress" : "Ended")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isActive ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
            .foregroundStyle(isActive ? .green : .gray)
            .clipShape(Capsule())
    }
}
