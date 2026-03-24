import SwiftUI

struct StreakSection: View {

    let currentWinStreak: Int
    let currentLossStreak: Int
    let longestWinStreak: Int
    let longestLossStreak: Int

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
                    color: Theme.accentGreen
                )

                streakCard(
                    label: "Current Loss",
                    value: currentLossStreak,
                    icon: "snowflake",
                    color: Theme.coldBlue
                )

                streakCard(
                    label: "Longest Win",
                    value: longestWinStreak,
                    icon: "crown.fill",
                    color: Theme.gold
                )

                streakCard(
                    label: "Longest Loss",
                    value: longestLossStreak,
                    icon: "exclamationmark.triangle.fill",
                    color: Theme.streakOrange
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
