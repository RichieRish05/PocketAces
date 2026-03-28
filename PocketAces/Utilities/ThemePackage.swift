import SwiftUI

enum ThemePackage: String, Codable, CaseIterable, Identifiable {
    case classic
    case ocean
    case emerald
    case sunset
    case lavender
    case fire
    case aurora
    case rose
    case coral
    case phantom

    var id: String { rawValue }

    // MARK: – Accent (bright highlight for buttons, icons, text)

    var accent: Color {
        switch self {
        case .classic:    Color(red: 1.0, green: 0.84, blue: 0.30)     // gold on green
        case .ocean:      Color(red: 0.40, green: 0.92, blue: 1.0)     // bright aqua
        case .emerald:    Color(red: 0.50, green: 1.0, blue: 0.75)     // luminous mint
        case .sunset:     Color(red: 1.0, green: 0.72, blue: 0.38)     // warm apricot
        case .lavender:   Color(red: 0.82, green: 0.65, blue: 1.0)     // soft lilac
        case .fire:       Color(red: 1.0, green: 0.85, blue: 0.25)     // blazing yellow
        case .aurora:     Color(red: 0.30, green: 1.0, blue: 0.85)     // electric cyan-green
        case .rose:       Color(red: 1.0, green: 0.72, blue: 0.82)     // soft rose pink
        case .coral:      Color(red: 1.0, green: 0.55, blue: 0.45)     // living coral
        case .phantom:    Color(red: 0.60, green: 0.85, blue: 0.95)    // spectral ice-blue
        }
    }

    // MARK: – Dim Accent (muted secondary, section headers)

    var dimAccent: Color {
        switch self {
        case .classic:    Color(red: 0.82, green: 0.68, blue: 0.22)
        case .ocean:      Color(red: 0.30, green: 0.70, blue: 0.80)
        case .emerald:    Color(red: 0.38, green: 0.78, blue: 0.58)
        case .sunset:     Color(red: 0.80, green: 0.55, blue: 0.28)
        case .lavender:   Color(red: 0.62, green: 0.48, blue: 0.80)
        case .fire:       Color(red: 0.82, green: 0.65, blue: 0.18)
        case .aurora:     Color(red: 0.22, green: 0.75, blue: 0.65)
        case .rose:       Color(red: 0.78, green: 0.52, blue: 0.62)
        case .coral:      Color(red: 0.78, green: 0.42, blue: 0.35)
        case .phantom:    Color(red: 0.45, green: 0.62, blue: 0.72)
        }
    }

    // MARK: – Primary (card backgrounds, main surfaces — the theme's signature color)

    var primary: Color {
        switch self {
        case .classic:    Color(red: 0.08, green: 0.42, blue: 0.22)     // forest green
        case .ocean:      Color(red: 0.06, green: 0.25, blue: 0.52)     // deep ocean blue
        case .emerald:    Color(red: 0.08, green: 0.42, blue: 0.32)     // deep emerald
        case .sunset:     Color(red: 0.52, green: 0.22, blue: 0.12)     // burnt sienna
        case .lavender:   Color(red: 0.28, green: 0.15, blue: 0.50)     // rich purple
        case .fire:       Color(red: 0.55, green: 0.12, blue: 0.08)     // deep crimson
        case .aurora:     Color(red: 0.05, green: 0.30, blue: 0.28)     // deep arctic teal
        case .rose:       Color(red: 0.48, green: 0.12, blue: 0.25)     // deep rose
        case .coral:      Color(red: 0.45, green: 0.18, blue: 0.15)     // deep coral
        case .phantom:    Color(red: 0.12, green: 0.10, blue: 0.22)     // dark iridescent
        }
    }

    // MARK: – Primary Dark (deepest backgrounds)

    var primaryDark: Color {
        switch self {
        case .classic:    Color(red: 0.04, green: 0.24, blue: 0.12)
        case .ocean:      Color(red: 0.03, green: 0.12, blue: 0.32)
        case .emerald:    Color(red: 0.04, green: 0.24, blue: 0.18)
        case .sunset:     Color(red: 0.30, green: 0.10, blue: 0.06)
        case .lavender:   Color(red: 0.15, green: 0.08, blue: 0.30)
        case .fire:       Color(red: 0.32, green: 0.06, blue: 0.04)
        case .aurora:     Color(red: 0.02, green: 0.14, blue: 0.16)
        case .rose:       Color(red: 0.28, green: 0.06, blue: 0.14)
        case .coral:      Color(red: 0.25, green: 0.08, blue: 0.08)
        case .phantom:    Color(red: 0.05, green: 0.04, blue: 0.12)
        }
    }

    // MARK: – Primary Mid (gradient midpoint)

    var primaryMid: Color {
        switch self {
        case .classic:    Color(red: 0.06, green: 0.32, blue: 0.16)
        case .ocean:      Color(red: 0.04, green: 0.18, blue: 0.42)
        case .emerald:    Color(red: 0.06, green: 0.32, blue: 0.25)
        case .sunset:     Color(red: 0.40, green: 0.15, blue: 0.08)
        case .lavender:   Color(red: 0.22, green: 0.12, blue: 0.40)
        case .fire:       Color(red: 0.42, green: 0.08, blue: 0.06)
        case .aurora:     Color(red: 0.04, green: 0.22, blue: 0.22)
        case .rose:       Color(red: 0.38, green: 0.08, blue: 0.20)
        case .coral:      Color(red: 0.35, green: 0.12, blue: 0.12)
        case .phantom:    Color(red: 0.08, green: 0.07, blue: 0.18)
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
        case .ocean:
            // Cyan → cerulean → deep indigo
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.8),
                    Color(red: 0, green: 0.7, blue: 0.9).opacity(0.75),
                    Color.blue.opacity(0.7),
                    Color(red: 0.2, green: 0.2, blue: 0.85).opacity(0.65),
                    Color.indigo.opacity(0.6),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .emerald:
            // Green → mint → deep teal
            LinearGradient(
                colors: [
                    Color.green.opacity(0.8),
                    Color(red: 0.2, green: 0.85, blue: 0.6).opacity(0.75),
                    Color.mint.opacity(0.7),
                    Color(red: 0.1, green: 0.75, blue: 0.7).opacity(0.65),
                    Color.teal.opacity(0.6),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sunset:
            // Warm orange → pink → deep red
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.8),
                    Color(red: 1.0, green: 0.5, blue: 0.3).opacity(0.75),
                    Color.pink.opacity(0.7),
                    Color(red: 0.95, green: 0.3, blue: 0.35).opacity(0.65),
                    Color.red.opacity(0.6),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .lavender:
            // Purple → indigo → deep blue
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color(red: 0.45, green: 0.2, blue: 0.8).opacity(0.75),
                    Color.indigo.opacity(0.7),
                    Color(red: 0.25, green: 0.2, blue: 0.75).opacity(0.65),
                    Color.blue.opacity(0.6),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .fire:
            // Red → molten orange → yellow
            LinearGradient(
                colors: [
                    Color.red.opacity(0.8),
                    Color(red: 1.0, green: 0.35, blue: 0.1).opacity(0.75),
                    Color.orange.opacity(0.7),
                    Color(red: 1.0, green: 0.75, blue: 0.2).opacity(0.65),
                    Color.yellow.opacity(0.6),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .aurora:
            // Electric green → teal → violet (northern lights)
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.95, blue: 0.6).opacity(0.75),
                    Color(red: 0.1, green: 0.8, blue: 0.7).opacity(0.72),
                    Color.teal.opacity(0.68),
                    Color(red: 0.3, green: 0.4, blue: 0.85).opacity(0.65),
                    Color(red: 0.45, green: 0.2, blue: 0.75).opacity(0.6),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .rose:
            // Hot pink → deep magenta → plum
            LinearGradient(
                colors: [
                    Color.pink.opacity(0.8),
                    Color(red: 0.9, green: 0.3, blue: 0.5).opacity(0.75),
                    Color(red: 0.7, green: 0.15, blue: 0.4).opacity(0.7),
                    Color(red: 0.5, green: 0.1, blue: 0.3).opacity(0.65),
                    Color(red: 0.35, green: 0.08, blue: 0.22).opacity(0.6),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .coral:
            // Living coral → warm turquoise → deep sea
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.38).opacity(0.78),
                    Color(red: 0.9, green: 0.38, blue: 0.32).opacity(0.72),
                    Color(red: 0.55, green: 0.35, blue: 0.38).opacity(0.68),
                    Color(red: 0.2, green: 0.42, blue: 0.52).opacity(0.65),
                    Color(red: 0.1, green: 0.35, blue: 0.5).opacity(0.6),
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
        case .ocean:
            LinearGradient(
                colors: [Color.cyan.opacity(0.35), Color.blue.opacity(0.30), Color.indigo.opacity(0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .emerald:
            LinearGradient(
                colors: [Color.green.opacity(0.35), Color.mint.opacity(0.30), Color.teal.opacity(0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .sunset:
            LinearGradient(
                colors: [Color.orange.opacity(0.35), Color.pink.opacity(0.30), Color.red.opacity(0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .lavender:
            LinearGradient(
                colors: [Color.purple.opacity(0.35), Color.indigo.opacity(0.30), Color.blue.opacity(0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .fire:
            LinearGradient(
                colors: [Color.red.opacity(0.35), Color.orange.opacity(0.30), Color.yellow.opacity(0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .aurora:
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.95, blue: 0.65).opacity(0.35), Color.teal.opacity(0.28), Color(red: 0.4, green: 0.25, blue: 0.75).opacity(0.22)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .rose:
            LinearGradient(
                colors: [Color.pink.opacity(0.35), Color(red: 0.7, green: 0.2, blue: 0.4).opacity(0.30), Color(red: 0.4, green: 0.1, blue: 0.25).opacity(0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .coral:
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.5, blue: 0.35).opacity(0.35), Color(red: 0.5, green: 0.4, blue: 0.42).opacity(0.28), Color(red: 0.15, green: 0.38, blue: 0.48).opacity(0.22)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .phantom:
            LinearGradient(
                colors: [Color(red: 0.4, green: 0.3, blue: 0.6).opacity(0.35), Color(red: 0.15, green: 0.3, blue: 0.45).opacity(0.28), Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.22)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }

    var displayName: String {
        switch self {
        case .classic:    "Classic"
        case .ocean:      "Ocean"
        case .emerald:    "Emerald"
        case .sunset:     "Sunset"
        case .lavender:   "Lavender"
        case .fire:       "Fire"
        case .aurora:     "Aurora"
        case .rose:       "Rose"
        case .coral:      "Coral"
        case .phantom:    "Phantom"
        }
    }
}
