import SwiftUI

struct GroupDetailView: View {
    let group: PokerGroup

    @Environment(\.dismiss) private var dismiss
    @Environment(UserStore.self) private var userStore
    @Environment(PokerGroupService.self) private var groupService
    @State private var loadedGroup: PokerGroup?
    @State private var isLoading = true
    @State private var showLeaveConfirmation = false
    @State private var isLeaving = false

    private var displayGroup: PokerGroup { loadedGroup ?? group }

    private var sortedMembers: [PokerGroupMember] {
        displayGroup.members.sorted { $0.totalProfit > $1.totalProfit }
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
        .navigationTitle(displayGroup.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            JoinCodeButton(joinCode: displayGroup.joinCode)
        }
        .task {
            guard let groupId = group.id else {
                isLoading = false
                return
            }
            do {
                loadedGroup = try await groupService.fetchGroup(id: groupId)
            } catch {
                // Fall back to the initially passed group
            }
            isLoading = false
        }
        .alert("Leave Group", isPresented: $showLeaveConfirmation) {
            Button("Leave", role: .destructive) {
                Task { await leaveGroup() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if displayGroup.members.count <= 1 {
                Text("You're the last member of \(displayGroup.name). Leaving will deactivate the group.")
            } else {
                Text("Are you sure you want to leave \(displayGroup.name)? You'll lose access to shared stats and game history.")
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

            if isLoading {
                VStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { _ in
                        LeaderboardRowSkeleton()
                    }
                }
            } else {
                let topTier = min(5, sortedMembers.count)

                ForEach(Array(sortedMembers.prefix(topTier).enumerated()), id: \.element.userId) { index, member in
                    LeaderboardRowView(rank: index + 1, member: member)
                }

                if sortedMembers.count > topTier {
                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)

                    ForEach(Array(sortedMembers.dropFirst(topTier).enumerated()), id: \.element.userId) { index, member in
                        LeaderboardRowView(rank: topTier + index + 1, member: member)
                    }
                }
            }
        }
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
}
