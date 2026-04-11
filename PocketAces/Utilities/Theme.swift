import SwiftUI

enum Theme {
    static let accent = Color(red: 0.85, green: 0.75, blue: 0.45)
    static let dimAccent = Color(red: 0.72, green: 0.65, blue: 0.42)
    static let primary = Color(red: 0.12, green: 0.42, blue: 0.28)
    static let primaryDark = Color(red: 0.06, green: 0.22, blue: 0.14)
    static let primaryMid = Color(red: 0.06, green: 0.32, blue: 0.16)

    static let gradient = LinearGradient(
        colors: [
            Color(red: 0.10, green: 0.44, blue: 0.24).opacity(0.65),
            Color(red: 0.04, green: 0.22, blue: 0.14).opacity(0.85),
            Color(red: 0.07, green: 0.34, blue: 0.18).opacity(0.72),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let borderGradient = LinearGradient(
        colors: [
            accent.opacity(0.35),
            Color.mint.opacity(0.15),
            accent.opacity(0.25),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let win = Color(red: 0.3, green: 0.85, blue: 0.45)
    static let loss = Color(red: 0.95, green: 0.35, blue: 0.35)
    static let silver = Color(red: 0.75, green: 0.82, blue: 0.9)
}
