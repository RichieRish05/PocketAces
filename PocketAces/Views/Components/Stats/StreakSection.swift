import SwiftUI

struct StreakSection: View {

    let currentWinStreak: Int
    let currentLossStreak: Int
    let longestWinStreak: Int
    let longestLossStreak: Int

    // MARK: - Palette

    private let gold = Color(red: 0.85, green: 0.75, blue: 0.45)
    private let accentGreen = Color(red: 0.3, green: 0.85, blue: 0.45)
    private let coldBlue = Color(red: 0.35, green: 0.7, blue: 1.0)
    private let orange = Color(red: 1.0, green: 0.55, blue: 0.0)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Streaks", icon: "flame.fill")

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                streakCard(
                    label: "Current Win",
                    value: currentWinStreak,
                    icon: "flame.fill",
                    color: accentGreen
                )

                streakCard(
                    label: "Current Loss",
                    value: currentLossStreak,
                    icon: "snowflake",
                    color: coldBlue
                )

                streakCard(
                    label: "Longest Win",
                    value: longestWinStreak,
                    icon: "crown.fill",
                    color: gold
                )

                streakCard(
                    label: "Longest Loss",
                    value: longestLossStreak,
                    icon: "exclamationmark.triangle.fill",
                    color: orange
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(white: 0.18), lineWidth: 1)
                )
        )
    }

    // MARK: - Streak Card

    private func streakCard(
        label: String,
        value: Int,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.35))
                    .tracking(0.3)
                    .textCase(.uppercase)

                Text("\(value)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) streak: \(value)")
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}
