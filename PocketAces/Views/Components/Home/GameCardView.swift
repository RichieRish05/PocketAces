import SwiftUI

enum SuitIcon: String, CaseIterable {
    case spade = "suit.spade.fill"
    case club = "suit.club.fill"
    case diamond = "suit.diamond.fill"
    case heart = "suit.heart.fill"

    static func from(gameId: String?) -> SuitIcon {
        guard let gameId, !gameId.isEmpty else { return .spade }
        let index = abs(gameId.hashValue) % allCases.count
        return allCases[index]
    }
}

struct GameCardView: View {
    let game: Game
    var peekNext: Bool = false

    private var suit: SuitIcon {
        .from(gameId: game.id ?? game.joinCode)
    }

    private var formattedPot: String {
        game.totalPot.formattedCompact()
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: suit.rawValue)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Theme.gold.opacity(0.7))

                Spacer()

                Text(game.joinCode)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }

            Spacer()

            Text(game.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)

            Text("\(game.activePlayerCount) players · \(formattedPot) pot")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(20)
        .frame(minHeight: 200)
        .containerRelativeFrame(.horizontal) { length, _ in
            max(length - (peekNext ? 56 : 32), 0)
        }
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Theme.feltGreen.opacity(0.6),
                        Theme.feltDark.opacity(0.8),
                        Color(red: 0.08, green: 0.30, blue: 0.22).opacity(0.7),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [
                        Color.mint.opacity(0.08),
                        Color.clear,
                    ],
                    center: .topLeading,
                    startRadius: 20,
                    endRadius: 200
                )

                RadialGradient(
                    colors: [
                        Color.cyan.opacity(0.06),
                        Color.clear,
                    ],
                    center: .bottomTrailing,
                    startRadius: 10,
                    endRadius: 180
                )

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Theme.gold.opacity(0.35),
                                Color.mint.opacity(0.15),
                                Theme.gold.opacity(0.25),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

}
