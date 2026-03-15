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

enum CardGradient: CaseIterable {
    
    case ocean
    case emerald
    case sunset
    case lavender
    case fire
    case midnight
    
    var colors: [Color] {
        switch self {
            
        case .ocean:
            return [
                Color.cyan.opacity(0.35),
                Color.blue.opacity(0.30),
                Color.indigo.opacity(0.25)
            ]
            
        case .emerald:
            return [
                Color.green.opacity(0.35),
                Color.mint.opacity(0.30),
                Color.teal.opacity(0.25)
            ]
            
        case .sunset:
            return [
                Color.orange.opacity(0.35),
                Color.pink.opacity(0.30),
                Color.red.opacity(0.25)
            ]
            
        case .lavender:
            return [
                Color.purple.opacity(0.35),
                Color.indigo.opacity(0.30),
                Color.blue.opacity(0.25)
            ]
            
        case .fire:
            return [
                Color.red.opacity(0.35),
                Color.orange.opacity(0.30),
                Color.yellow.opacity(0.25)
            ]
            
        case .midnight:
            return [
                Color.indigo.opacity(0.35),
                Color.black.opacity(0.30),
                Color.blue.opacity(0.25)
            ]
        }
    }
    
    static func from(gameId: String?) -> CardGradient {
        guard let gameId, !gameId.isEmpty else { return .sunset }
        let index = abs(gameId.hashValue) % allCases.count
        return allCases[index]
    }
}


struct GameCardView: View {
    let game: Game

    private var suit: SuitIcon {
        .from(gameId: game.id ?? game.joinCode)
    }
    
    private var cardGradient: CardGradient {
        .from(gameId: game.id ?? game.joinCode)
    }

    private var formattedPot: String {
        formatCompact(game.totalPot)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: suit.rawValue)
                    .font(.system(size: 64))
                    .foregroundStyle(.white.opacity(0.85))
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

                Spacer()

                Text(game.joinCode)
                    .foregroundStyle(.secondary)


            }

            Spacer()

            Text(game.name)
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text("\(game.playerCount) players •  \(formattedPot) pot")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(minHeight: 220)
        .containerRelativeFrame(.horizontal) { length, _ in
            length - 32
        }
        .background(
            LinearGradient(
                colors: cardGradient.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func formatCompact(_ value: Double) -> String {
        if value >= 1000 {
            let k = value / 1000
            return k.truncatingRemainder(dividingBy: 1) == 0
                ? "\(Int(k))k"
                : String(format: "%.1fk", k)
        }
        return value.truncatingRemainder(dividingBy: 1) == 0
            ? "$\(Int(value))"
            : String(format: "$%.0f", value)
    }
}
