import SwiftUI

struct GroupCardView: View {
    let group: PokerGroup

    private var formattedDate: String {
        group.createdAt.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.3")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.accent.opacity(0.85))

                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text("Created \(formattedDate)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .padding(16)
        .background(
            ZStack {
                Theme.gradient

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        Theme.borderGradient,
                        lineWidth: 1
                    )
            }
        )
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
