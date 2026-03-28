import SwiftUI

enum ThemePackage: String, Codable, CaseIterable, Identifiable {
    case classic
    case midnight
    case ember
    case ocean

    var id: String { rawValue }

    var accent: Color {
        switch self {
        case .classic:  Color(red: 0.85, green: 0.75, blue: 0.45)
        case .midnight: Color(red: 0.55, green: 0.65, blue: 0.95)
        case .ember:    Color(red: 0.90, green: 0.65, blue: 0.30)
        case .ocean:    Color(red: 0.25, green: 0.80, blue: 0.75)
        }
    }

    var dimAccent: Color {
        switch self {
        case .classic:  Color(red: 0.72, green: 0.65, blue: 0.42)
        case .midnight: Color(red: 0.40, green: 0.50, blue: 0.78)
        case .ember:    Color(red: 0.75, green: 0.52, blue: 0.25)
        case .ocean:    Color(red: 0.20, green: 0.62, blue: 0.60)
        }
    }

    var primary: Color {
        switch self {
        case .classic:  Color(red: 0.12, green: 0.42, blue: 0.28)
        case .midnight: Color(red: 0.10, green: 0.12, blue: 0.28)
        case .ember:    Color(red: 0.22, green: 0.18, blue: 0.14)
        case .ocean:    Color(red: 0.08, green: 0.18, blue: 0.30)
        }
    }

    var primaryDark: Color {
        switch self {
        case .classic:  Color(red: 0.06, green: 0.22, blue: 0.14)
        case .midnight: Color(red: 0.05, green: 0.06, blue: 0.15)
        case .ember:    Color(red: 0.12, green: 0.10, blue: 0.08)
        case .ocean:    Color(red: 0.04, green: 0.10, blue: 0.18)
        }
    }

    var primaryMid: Color {
        switch self {
        case .classic:  Color(red: 0.08, green: 0.30, blue: 0.22)
        case .midnight: Color(red: 0.08, green: 0.09, blue: 0.22)
        case .ember:    Color(red: 0.18, green: 0.14, blue: 0.11)
        case .ocean:    Color(red: 0.06, green: 0.14, blue: 0.24)
        }
    }

    var displayName: String {
        switch self {
        case .classic:  "Classic"
        case .midnight: "Midnight"
        case .ember:    "Ember"
        case .ocean:    "Ocean"
        }
    }
}
