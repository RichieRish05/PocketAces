import SwiftUI

enum HeatLevel: Int, CaseIterable {
    case freezing = -3
    case cold = -2
    case cool = -1
    case neutral = 0
    case warm = 1
    case hot = 2
    case onFire = 3

    var icon: String {
        switch self {
        case .freezing: "snowflake"
        case .cold: "cloud.snow.fill"
        case .cool: "thermometer.low"
        case .neutral: "minus.circle"
        case .warm: "thermometer.medium"
        case .hot: "flame.fill"
        case .onFire: "sun.max.fill"
        }
    }

    var label: String {
        switch self {
        case .freezing: "Absolute Bloodbath"
        case .cold: "Ice Cold Run"
        case .cool: "Running Cold"
        case .neutral: "On Pace"
        case .warm: "Heating Up"
        case .hot: "On a Heater"
        case .onFire: "UNREAL HEATER"
        }
    }

    var color: Color {
        switch self {
        case .freezing: Color(red: 0.3, green: 0.55, blue: 1.0)
        case .cold: Color(red: 0.35, green: 0.7, blue: 1.0)
        case .cool: Color(red: 0.3, green: 0.85, blue: 1.0)
        case .neutral: Color(white: 0.7)
        case .warm: Color(red: 1.0, green: 0.75, blue: 0.15)
        case .hot: Color(red: 1.0, green: 0.45, blue: 0.05)
        case .onFire: Color(red: 1.0, green: 0.2, blue: 0.15)
        }
    }

    
    var gradient: LinearGradient {
        switch self {
        case .freezing:
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.2, blue: 1.0),   // deep electric blue
                    Color(red: 0.4, green: 0.85, blue: 1.0)  // icy cyan glow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .cold:
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.45, blue: 1.0),  // strong blue
                    Color(red: 0.5, green: 0.9, blue: 1.0)   // bright aqua
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .cool:
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.7, blue: 1.0),   // cyan pop
                    Color(red: 0.6, green: 1.0, blue: 0.95)  // mint highlight
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .neutral:
            LinearGradient(
                colors: [
                    Color(red: 0.3, green: 0.3, blue: 0.35), // dark slate
                    Color(red: 0.7, green: 0.7, blue: 0.75)  // light silver
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .warm:
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.0),   // bright orange
                    Color(red: 1.0, green: 0.9, blue: 0.3)   // golden glow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .hot:
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.2, blue: 0.0),   // intense red-orange
                    Color(red: 1.0, green: 0.7, blue: 0.1)   // fiery amber
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .onFire:
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.0, blue: 0.2),   // neon red
                    Color(red: 1.0, green: 0.85, blue: 0.0)  // blazing yellow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
