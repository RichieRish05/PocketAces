import SwiftUI

struct GroupDetailView: View {
    let group: PokerGroup

    @Environment(\.dismiss) private var dismiss
    @Environment(UserStore.self) private var userStore
    @Environment(PokerGroupService.self) private var groupService
    @State private var showLeaveConfirmation = false
    @State private var isLeaving = false

    private var sortedMembers: [PokerGroupMember] {
        group.members.sorted { $0.totalProfit > $1.totalProfit }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                leaderboard
                    .padding(.top, 20)

                leaveButton
                    .padding(.top, 32)
                    .padding(.bottom, 48)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.black)
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            JoinCodeButton(joinCode: group.joinCode)
        }
        .alert("Leave Group", isPresented: $showLeaveConfirmation) {
            Button("Leave", role: .destructive) {
                Task { await leaveGroup() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if group.members.count <= 1 {
                Text("You're the last member of \(group.name). Leaving will deactivate the group.")
            } else {
                Text("Are you sure you want to leave \(group.name)? You'll lose access to shared stats and game history.")
            }
        }
    }

    // MARK: - Leaderboard

    private var leaderboard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("LEADERBOARD")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.dimAccent)
                .tracking(1.5)
                .padding(.horizontal, 20)
                .padding(.bottom, 14)

            let topTier = min(5, sortedMembers.count)

            ForEach(Array(sortedMembers.prefix(topTier).enumerated()), id: \.element.userId) { index, member in
                leaderboardRow(rank: index + 1, member: member)
            }

            if sortedMembers.count > topTier {
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)

                ForEach(Array(sortedMembers.dropFirst(topTier).enumerated()), id: \.element.userId) { index, member in
                    leaderboardRow(rank: topTier + index + 1, member: member)
                }
            }
        }
    }

    private func leaderboardRow(rank: Int, member: PokerGroupMember) -> some View {
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

    // MARK: - Leave Button

    private var leaveButton: some View {
        Button {
            showLeaveConfirmation = true
        } label: {
            Group {
                if isLeaving {
                    ProgressView()
                        .tint(Theme.accent)
                } else {
                    Text("Leave Group")
                }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Theme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(isLeaving)
        .padding(.horizontal, 16)
    }

    // MARK: - Actions

    private func leaveGroup() async {
        guard let groupId = group.id else { return }
        let userId = userStore.userData?.id ?? ""
        isLeaving = true
        do {
            try await groupService.leaveGroup(groupId: groupId, userId: userId)
            if var updated = userStore.userData {
                updated.activeGroups.removeAll { $0 == groupId }
                userStore.save(updated)
            }
            dismiss()
        } catch {
            isLeaving = false
        }
    }

    // MARK: - Helpers

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
