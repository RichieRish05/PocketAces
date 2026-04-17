import SwiftUI

struct GroupRowView: View {
    let group: PokerGroup

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.gradient)
                    .frame(width: 36, height: 36)

                Image(systemName: "person.3.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.accent)
            }


            Text(group.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)


            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.2))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

struct GroupRowSkeleton: View {
    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 100, height: 12)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 70, height: 10)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .redacted(reason: .placeholder)
    }
}

struct EmptyGroupsView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.3")
                .font(.system(size: 20))
                .foregroundStyle(.white.opacity(0.3))

            Text("Join or create a group to get started")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
