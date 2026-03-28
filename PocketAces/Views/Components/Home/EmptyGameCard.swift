import SwiftUI

struct EmptyTableCard: View {
    @State private var animate = false

    private let suits: [(icon: String, color: Color, x: CGFloat, y: CGFloat, size: CGFloat, rotation: Double, delay: Double)] = [
        ("suit.spade.fill",   .cyan,    0.10, 0.22, 28, -15,  0.0),
        ("suit.heart.fill",   .pink,    0.88, 0.18, 24,  20,  0.3),
        ("suit.diamond.fill", .orange,  0.82, 0.72, 22, -10,  0.6),
        ("suit.club.fill",    .mint,    0.14, 0.76, 26,  12,  0.9),
        ("suit.heart.fill",   .red,     0.50, 0.08, 18,   8,  0.2),
        ("suit.spade.fill",   .indigo,  0.68, 0.88, 20, -22,  0.5),
        ("suit.diamond.fill", .yellow,  0.30, 0.92, 16,  18,  0.7),
        ("suit.club.fill",    .purple,  0.92, 0.45, 18,  -8,  1.1),
    ]

    var body: some View {
        ZStack {
            // Center content
            VStack(spacing: 16) {

                // Ace of spades
                Image(systemName: "suit.spade.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Theme.shared.accent)


                VStack(spacing: 5) {
                    Text("The table's empty")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))

                    Text("Deal yourself in, host or join a game")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(
            ZStack {
                Theme.shared.gradient

                // Subtle noise texture feel via layered radials
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

                // Gold-tinted border
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        Theme.shared.borderGradient,
                        lineWidth: 1
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onAppear {
            animate = true
        }
    }
}
