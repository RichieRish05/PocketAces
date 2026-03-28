import SwiftUI

@Observable
final class Theme {
    static let shared = Theme()

    // Dynamic — change with ThemePackage
    private(set) var accent: Color
    private(set) var dimAccent: Color
    private(set) var primary: Color
    private(set) var primaryDark: Color

    // Fixed — never change
    static let win = Color(red: 0.3, green: 0.85, blue: 0.45)
    static let loss = Color(red: 0.95, green: 0.35, blue: 0.35)
    static let silver = Color(red: 0.75, green: 0.82, blue: 0.9)

    private init() {
        let initial = ThemePackage.classic
        accent = initial.accent
        dimAccent = initial.dimAccent
        primary = initial.primary
        primaryDark = initial.primaryDark
    }

    func apply(_ package: ThemePackage) {
        accent = package.accent
        dimAccent = package.dimAccent
        primary = package.primary
        primaryDark = package.primaryDark
    }
}
