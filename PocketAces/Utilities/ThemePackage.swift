import SwiftUI

enum ThemePackage: String, Codable, CaseIterable, Identifiable {
    case classic
    case rose
    case phantom
    case sapphire
    case merlot
    case obsidian
    case abyss
    case ember
    case jade
    case velvet
    case twilight
    case bourbon

    var id: String { rawValue }

    // MARK: – Accent (bright highlight for buttons, icons, text)

    var accent: Color {
        switch self {
        case .classic:    Color(red: 1.0, green: 0.84, blue: 0.30)     // gold
        case .rose:       Color(red: 1.0, green: 0.72, blue: 0.82)     // soft rose pink
        case .phantom:    Color(red: 0.60, green: 0.85, blue: 0.95)    // spectral ice-blue
        case .sapphire:   Color(red: 0.55, green: 0.78, blue: 1.0)     // bright sapphire
        case .merlot:     Color(red: 1.0, green: 0.90, blue: 0.78)     // warm champagne
        case .obsidian:   Color(red: 0.92, green: 0.68, blue: 0.42)    // burnished copper
        case .abyss:      Color(red: 0.30, green: 0.95, blue: 0.80)    // bioluminescent cyan
        case .ember:      Color(red: 1.0, green: 0.72, blue: 0.32)     // warm amber
        case .jade:       Color(red: 0.62, green: 0.92, blue: 0.72)    // pale jade
        case .velvet:     Color(red: 0.92, green: 0.78, blue: 0.45)    // antique gold
        case .twilight:   Color(red: 1.0, green: 0.75, blue: 0.62)     // warm peach
        case .bourbon:    Color(red: 1.0, green: 0.82, blue: 0.40)     // aged gold
        }
    }

    // MARK: – Dim Accent (muted secondary, section headers)

    var dimAccent: Color {
        switch self {
        case .classic:    Color(red: 0.82, green: 0.68, blue: 0.22)
        case .rose:       Color(red: 0.78, green: 0.52, blue: 0.62)
        case .phantom:    Color(red: 0.45, green: 0.62, blue: 0.72)
        case .sapphire:   Color(red: 0.40, green: 0.58, blue: 0.78)
        case .merlot:     Color(red: 0.75, green: 0.65, blue: 0.55)
        case .obsidian:   Color(red: 0.68, green: 0.50, blue: 0.32)
        case .abyss:      Color(red: 0.22, green: 0.68, blue: 0.58)
        case .ember:      Color(red: 0.78, green: 0.55, blue: 0.24)
        case .jade:       Color(red: 0.45, green: 0.70, blue: 0.52)
        case .velvet:     Color(red: 0.70, green: 0.58, blue: 0.35)
        case .twilight:   Color(red: 0.75, green: 0.55, blue: 0.45)
        case .bourbon:    Color(red: 0.78, green: 0.60, blue: 0.30)
        }
    }

    // MARK: – Primary (card backgrounds, main surfaces — the theme's signature color)

    var primary: Color {
        switch self {
        case .classic:    Color(red: 0.08, green: 0.42, blue: 0.22)     // forest green
        case .rose:       Color(red: 0.48, green: 0.12, blue: 0.25)     // deep rose
        case .phantom:    Color(red: 0.12, green: 0.10, blue: 0.22)     // dark iridescent
        case .sapphire:   Color(red: 0.08, green: 0.18, blue: 0.48)     // deep sapphire
        case .merlot:     Color(red: 0.42, green: 0.08, blue: 0.18)     // deep wine
        case .obsidian:   Color(red: 0.18, green: 0.14, blue: 0.12)     // warm obsidian
        case .abyss:      Color(red: 0.04, green: 0.22, blue: 0.26)     // deep sea
        case .ember:      Color(red: 0.40, green: 0.14, blue: 0.06)     // smoldering dark
        case .jade:       Color(red: 0.06, green: 0.28, blue: 0.18)     // deep mineral green
        case .velvet:     Color(red: 0.28, green: 0.10, blue: 0.38)     // deep royal purple
        case .twilight:   Color(red: 0.14, green: 0.10, blue: 0.35)     // deep twilight navy
        case .bourbon:    Color(red: 0.38, green: 0.22, blue: 0.08)     // deep whiskey
        }
    }

    // MARK: – Primary Dark (deepest backgrounds)

    var primaryDark: Color {
        switch self {
        case .classic:    Color(red: 0.04, green: 0.24, blue: 0.12)
        case .rose:       Color(red: 0.28, green: 0.06, blue: 0.14)
        case .phantom:    Color(red: 0.05, green: 0.04, blue: 0.12)
        case .sapphire:   Color(red: 0.04, green: 0.08, blue: 0.28)
        case .merlot:     Color(red: 0.24, green: 0.04, blue: 0.10)
        case .obsidian:   Color(red: 0.08, green: 0.06, blue: 0.05)
        case .abyss:      Color(red: 0.02, green: 0.10, blue: 0.14)
        case .ember:      Color(red: 0.22, green: 0.06, blue: 0.02)
        case .jade:       Color(red: 0.03, green: 0.15, blue: 0.10)
        case .velvet:     Color(red: 0.14, green: 0.04, blue: 0.22)
        case .twilight:   Color(red: 0.06, green: 0.04, blue: 0.18)
        case .bourbon:    Color(red: 0.20, green: 0.10, blue: 0.03)
        }
    }

    // MARK: – Primary Mid (gradient midpoint)

    var primaryMid: Color {
        switch self {
        case .classic:    Color(red: 0.06, green: 0.32, blue: 0.16)
        case .rose:       Color(red: 0.38, green: 0.08, blue: 0.20)
        case .phantom:    Color(red: 0.08, green: 0.07, blue: 0.18)
        case .sapphire:   Color(red: 0.06, green: 0.12, blue: 0.38)
        case .merlot:     Color(red: 0.32, green: 0.06, blue: 0.14)
        case .obsidian:   Color(red: 0.12, green: 0.10, blue: 0.08)
        case .abyss:      Color(red: 0.03, green: 0.16, blue: 0.20)
        case .ember:      Color(red: 0.30, green: 0.10, blue: 0.04)
        case .jade:       Color(red: 0.04, green: 0.22, blue: 0.14)
        case .velvet:     Color(red: 0.22, green: 0.06, blue: 0.30)
        case .twilight:   Color(red: 0.10, green: 0.07, blue: 0.28)
        case .bourbon:    Color(red: 0.28, green: 0.16, blue: 0.05)
        }
    }

    // MARK: – Gradient (bespoke per-theme card background)

    var gradient: LinearGradient {
        switch self {
        case .classic:
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.44, blue: 0.24).opacity(0.65),
                    Color(red: 0.04, green: 0.22, blue: 0.14).opacity(0.85),
                    Color(red: 0.07, green: 0.34, blue: 0.18).opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .rose:
            // Hot pink → deep magenta → plum
            LinearGradient(
                colors: [
                    Color(red: 0.52, green: 0.14, blue: 0.28).opacity(0.78),
                    Color(red: 0.40, green: 0.08, blue: 0.22).opacity(0.82),
                    Color(red: 0.30, green: 0.05, blue: 0.16).opacity(0.85),
                    Color(red: 0.22, green: 0.04, blue: 0.12).opacity(0.80),
                    Color(red: 0.35, green: 0.06, blue: 0.20).opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .phantom:
            // Iridescent: purple → teal → deep void
            LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.2, blue: 0.55).opacity(0.78),
                    Color(red: 0.2, green: 0.25, blue: 0.5).opacity(0.72),
                    Color(red: 0.1, green: 0.3, blue: 0.42).opacity(0.68),
                    Color(red: 0.08, green: 0.18, blue: 0.28).opacity(0.65),
                    Color(red: 0.04, green: 0.06, blue: 0.14).opacity(0.6),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sapphire:
            // Deep faceted blue → midnight navy
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.22, blue: 0.55).opacity(0.78),
                    Color(red: 0.06, green: 0.15, blue: 0.45).opacity(0.82),
                    Color(red: 0.04, green: 0.10, blue: 0.35).opacity(0.85),
                    Color(red: 0.03, green: 0.08, blue: 0.28).opacity(0.80),
                    Color(red: 0.05, green: 0.12, blue: 0.38).opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .merlot:
            // Deep wine → black cherry → burgundy
            LinearGradient(
                colors: [
                    Color(red: 0.48, green: 0.10, blue: 0.20).opacity(0.78),
                    Color(red: 0.35, green: 0.06, blue: 0.15).opacity(0.82),
                    Color(red: 0.25, green: 0.04, blue: 0.10).opacity(0.85),
                    Color(red: 0.18, green: 0.03, blue: 0.08).opacity(0.80),
                    Color(red: 0.32, green: 0.05, blue: 0.14).opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .obsidian:
            // Warm charcoal → ember-tinged black
            LinearGradient(
                colors: [
                    Color(red: 0.22, green: 0.17, blue: 0.14).opacity(0.80),
                    Color(red: 0.15, green: 0.11, blue: 0.09).opacity(0.85),
                    Color(red: 0.10, green: 0.07, blue: 0.06).opacity(0.88),
                    Color(red: 0.06, green: 0.05, blue: 0.04).opacity(0.82),
                    Color(red: 0.14, green: 0.10, blue: 0.08).opacity(0.75),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .abyss:
            // Dark teal → bioluminescent depth → void
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.28, blue: 0.30).opacity(0.78),
                    Color(red: 0.03, green: 0.20, blue: 0.24).opacity(0.82),
                    Color(red: 0.02, green: 0.14, blue: 0.18).opacity(0.85),
                    Color(red: 0.01, green: 0.08, blue: 0.12).opacity(0.80),
                    Color(red: 0.03, green: 0.18, blue: 0.22).opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ember:
            // Smoldering red-brown → deep char
            LinearGradient(
                colors: [
                    Color(red: 0.45, green: 0.16, blue: 0.06).opacity(0.78),
                    Color(red: 0.35, green: 0.10, blue: 0.04).opacity(0.82),
                    Color(red: 0.25, green: 0.07, blue: 0.03).opacity(0.85),
                    Color(red: 0.18, green: 0.05, blue: 0.02).opacity(0.80),
                    Color(red: 0.32, green: 0.08, blue: 0.04).opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .jade:
            // Deep mineral green → dark stone
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.32, blue: 0.22).opacity(0.78),
                    Color(red: 0.05, green: 0.24, blue: 0.16).opacity(0.82),
                    Color(red: 0.03, green: 0.18, blue: 0.12).opacity(0.85),
                    Color(red: 0.02, green: 0.12, blue: 0.08).opacity(0.80),
                    Color(red: 0.05, green: 0.22, blue: 0.15).opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .velvet:
            // Deep royal purple → dark amethyst
            LinearGradient(
                colors: [
                    Color(red: 0.32, green: 0.12, blue: 0.42).opacity(0.78),
                    Color(red: 0.24, green: 0.08, blue: 0.34).opacity(0.82),
                    Color(red: 0.16, green: 0.05, blue: 0.26).opacity(0.85),
                    Color(red: 0.10, green: 0.03, blue: 0.18).opacity(0.80),
                    Color(red: 0.22, green: 0.06, blue: 0.32).opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .twilight:
            // Deep navy → purple → dark violet
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.12, blue: 0.40).opacity(0.78),
                    Color(red: 0.12, green: 0.08, blue: 0.35).opacity(0.82),
                    Color(red: 0.18, green: 0.06, blue: 0.32).opacity(0.85),
                    Color(red: 0.08, green: 0.04, blue: 0.20).opacity(0.80),
                    Color(red: 0.14, green: 0.08, blue: 0.30).opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .bourbon:
            // Aged amber → dark oak → deep char
            LinearGradient(
                colors: [
                    Color(red: 0.42, green: 0.25, blue: 0.10).opacity(0.78),
                    Color(red: 0.32, green: 0.18, blue: 0.06).opacity(0.82),
                    Color(red: 0.22, green: 0.12, blue: 0.04).opacity(0.85),
                    Color(red: 0.15, green: 0.08, blue: 0.03).opacity(0.80),
                    Color(red: 0.28, green: 0.15, blue: 0.05).opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: – Border Gradient (bespoke per-theme stroke)

    var borderGradient: LinearGradient {
        switch self {
        case .classic:
            LinearGradient(
                colors: [accent.opacity(0.35), Color.mint.opacity(0.15), accent.opacity(0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .rose:
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.55, blue: 0.68).opacity(0.32), Color(red: 0.7, green: 0.2, blue: 0.4).opacity(0.22), Color(red: 0.45, green: 0.12, blue: 0.28).opacity(0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .phantom:
            LinearGradient(
                colors: [Color(red: 0.4, green: 0.3, blue: 0.6).opacity(0.32), Color(red: 0.15, green: 0.3, blue: 0.45).opacity(0.22), Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .sapphire:
            LinearGradient(
                colors: [Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.32), Color(red: 0.15, green: 0.3, blue: 0.7).opacity(0.22), Color(red: 0.08, green: 0.15, blue: 0.45).opacity(0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .merlot:
            LinearGradient(
                colors: [Color(red: 0.8, green: 0.45, blue: 0.5).opacity(0.32), Color(red: 0.55, green: 0.18, blue: 0.25).opacity(0.22), Color(red: 0.35, green: 0.08, blue: 0.15).opacity(0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .obsidian:
            LinearGradient(
                colors: [Color(red: 0.7, green: 0.52, blue: 0.35).opacity(0.32), Color(red: 0.4, green: 0.28, blue: 0.18).opacity(0.22), Color(red: 0.2, green: 0.15, blue: 0.1).opacity(0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .abyss:
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.75, blue: 0.65).opacity(0.32), Color(red: 0.08, green: 0.45, blue: 0.42).opacity(0.22), Color(red: 0.04, green: 0.22, blue: 0.25).opacity(0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .ember:
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.55, blue: 0.22).opacity(0.32), Color(red: 0.65, green: 0.28, blue: 0.1).opacity(0.22), Color(red: 0.38, green: 0.12, blue: 0.05).opacity(0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .jade:
            LinearGradient(
                colors: [Color(red: 0.45, green: 0.78, blue: 0.55).opacity(0.32), Color(red: 0.2, green: 0.52, blue: 0.32).opacity(0.22), Color(red: 0.08, green: 0.3, blue: 0.18).opacity(0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .velvet:
            LinearGradient(
                colors: [Color(red: 0.7, green: 0.45, blue: 0.85).opacity(0.32), Color(red: 0.42, green: 0.2, blue: 0.58).opacity(0.22), Color(red: 0.22, green: 0.08, blue: 0.35).opacity(0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .twilight:
            LinearGradient(
                colors: [Color(red: 0.8, green: 0.55, blue: 0.45).opacity(0.32), Color(red: 0.4, green: 0.2, blue: 0.5).opacity(0.22), Color(red: 0.15, green: 0.08, blue: 0.3).opacity(0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .bourbon:
            LinearGradient(
                colors: [Color(red: 0.85, green: 0.62, blue: 0.28).opacity(0.32), Color(red: 0.55, green: 0.35, blue: 0.12).opacity(0.22), Color(red: 0.30, green: 0.18, blue: 0.06).opacity(0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }

    var displayName: String {
        switch self {
        case .classic:    "Classic"
        case .rose:       "Rose"
        case .phantom:    "Phantom"
        case .sapphire:   "Sapphire"
        case .merlot:     "Merlot"
        case .obsidian:   "Obsidian"
        case .abyss:      "Abyss"
        case .ember:      "Ember"
        case .jade:       "Jade"
        case .velvet:     "Velvet"
        case .twilight:   "Twilight"
        case .bourbon:    "Bourbon"
        }
    }
}
