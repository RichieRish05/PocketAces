import SwiftUI

enum ThemePackage: String, Codable, CaseIterable, Identifiable {
    case classic, midnight, royal, crimson

    var id: String { rawValue }

    var accent: Color {
        switch self {
        case .classic:  Color(red: 0.85, green: 0.75, blue: 0.45)
        case .midnight: Color(red: 0.55, green: 0.78, blue: 0.95)
        case .royal:    Color(red: 0.72, green: 0.52, blue: 0.95)
        case .crimson:  Color(red: 0.95, green: 0.45, blue: 0.55)
        }
    }

    var dimAccent: Color {
        switch self {
        case .classic:  Color(red: 0.72, green: 0.65, blue: 0.42)
        case .midnight: Color(red: 0.42, green: 0.6, blue: 0.78)
        case .royal:    Color(red: 0.55, green: 0.4, blue: 0.75)
        case .crimson:  Color(red: 0.78, green: 0.35, blue: 0.45)
        }
    }

    var primary: Color {
        switch self {
        case .classic:  Color(red: 0.12, green: 0.42, blue: 0.28)
        case .midnight: Color(red: 0.1, green: 0.15, blue: 0.3)
        case .royal:    Color(red: 0.2, green: 0.1, blue: 0.35)
        case .crimson:  Color(red: 0.35, green: 0.1, blue: 0.15)
        }
    }

    var primaryDark: Color {
        switch self {
        case .classic:  Color(red: 0.06, green: 0.22, blue: 0.14)
        case .midnight: Color(red: 0.05, green: 0.08, blue: 0.18)
        case .royal:    Color(red: 0.1, green: 0.05, blue: 0.2)
        case .crimson:  Color(red: 0.2, green: 0.05, blue: 0.1)
        }
    }

    var displayName: String {
        switch self {
        case .classic:  "Classic"
        case .midnight: "Midnight"
        case .royal:    "Royal"
        case .crimson:  "Crimson"
        }
    }
}
