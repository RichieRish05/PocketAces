import SwiftUI

enum HeatLevel: Int, CaseIterable {
    case freezing = 0
    case cold = 1
    case cool = 2
    case neutral = 3
    case warm = 4
    case hot = 5
    case onFire = 6

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
        case .neutral: Color(red: 0.75, green: 0.82, blue: 0.9)
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
                    Color(red: 0.0, green: 0.05, blue: 0.5),   // deep navy
                    Color(red: 0.0, green: 0.35, blue: 1.0),   // electric blue
                    Color(red: 0.6, green: 0.95, blue: 1.0)    // icy glow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .cold:
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.2, blue: 0.9),    // rich blue
                    Color(red: 0.0, green: 0.6, blue: 1.0),    // bright aqua
                    Color(red: 0.7, green: 1.0, blue: 1.0)     // cool glow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .cool:
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.5, blue: 0.9),    // cyan base
                    Color(red: 0.2, green: 0.9, blue: 1.0),    // vibrant cyan
                    Color(red: 0.7, green: 1.0, blue: 0.9)     // mint glow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .neutral:
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),   // crisp white highlight
                    Color(red: 0.75, green: 0.82, blue: 0.9),   // cool silver-blue mid
                    Color(red: 0.55, green: 0.6, blue: 0.7)     // steel depth
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .warm:
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.35, blue: 0.0),    // deep orange
                    Color(red: 1.0, green: 0.65, blue: 0.0),    // vivid orange
                    Color(red: 1.0, green: 0.95, blue: 0.4)     // golden glow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .hot:
            LinearGradient(
                colors: [
                    Color(red: 0.8, green: 0.0, blue: 0.0),     // deep red
                    Color(red: 1.0, green: 0.2, blue: 0.0),     // bright red-orange
                    Color(red: 1.0, green: 0.8, blue: 0.2)      // fiery glow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .onFire:
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.0, blue: 0.1),     // dark crimson
                    Color(red: 1.0, green: 0.0, blue: 0.2),     // neon red
                    Color(red: 1.0, green: 0.95, blue: 0.0)     // explosive yellow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
