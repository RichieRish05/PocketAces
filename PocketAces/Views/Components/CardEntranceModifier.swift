import SwiftUI

struct CardEntranceModifier: ViewModifier {
    let index: Int
    let appeared: Bool

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(
                .spring(duration: 0.5, bounce: 0.15)
                    .delay(Double(index) * 0.05),
                value: appeared
            )
    }
}

extension View {
    func cardEntrance(index: Int, appeared: Bool) -> some View {
        modifier(CardEntranceModifier(index: index, appeared: appeared))
    }
}
