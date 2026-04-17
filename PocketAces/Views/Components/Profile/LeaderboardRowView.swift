import SwiftUI

struct LeaderboardRowView: View {
    let rank: Int
    let member: PokerGroupMember

    var body: some View {
        HStack(spacing: 14) {
            Group {
                if rank <= 3 {
                    Text(rankMedal(rank))
                        .font(.system(size: 28))
                } else {
                    Text("\(rank)")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .frame(width: 40)

            Image(member.avatarName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(member.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(profitString(member.totalProfit))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(member.totalProfit >= 0 ? Theme.accent.opacity(0.7) : .red.opacity(0.6))
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private func rankMedal(_ rank: Int) -> String {
        switch rank {
        case 1: "🥇"
        case 2: "🥈"
        case 3: "🥉"
        default: ""
        }
    }

    private func profitString(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : "-"
        return "\(sign)$\(String(format: "%.0f", abs(value)))"
    }
}

struct LeaderboardRowSkeleton: View {
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.06))
                .frame(width: 24, height: 16)
                .frame(width: 40)

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 100, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 60, height: 11)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .redacted(reason: .placeholder)
    }
}
