import SwiftUI

struct ProfileView: View {
    @Environment(UserStore.self) private var userStore
    @Environment(PokerGroupService.self) private var pokerGroupService
    @State private var viewModel = ProfileViewModel()
    @State private var groupViewModel = GroupViewModel()
    @State private var appeared = false

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    profileCard
                        .padding(.horizontal, 20)
                    groupActionRow
                    groupsSection
                }
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.load(from: userStore)
                groupViewModel.load(from: userStore, groupService: pokerGroupService)
                withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                    appeared = true
                }
            }
            .navigationDestination(for: ProfileDestination.self) { destination in
                switch destination {
                case .avatarPicker:
                    AvatarPickerView(viewModel: viewModel)
                case .groupDetail(let group):
                    GroupDetailView(group: group)
                }
            }
            .sheet(isPresented: $viewModel.showNameEditor) {
                NameEditorSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $groupViewModel.showCreateSheet) {
                CreateGroupSheet(viewModel: groupViewModel)
            }
            .sheet(isPresented: $groupViewModel.showJoinSheet) {
                JoinGroupSheet(viewModel: groupViewModel)
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(spacing: 20) {
            Spacer()
            avatarSection
            nameSection
            if !viewModel.memberSinceText.isEmpty {
                Text(viewModel.memberSinceText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(white: 0.45))
            }
        }
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, minHeight: 328)
    }

    // MARK: - Avatar

    private var avatarSection: some View {
        Button {
            viewModel.beginPickingAvatar()
        } label: {
            Image(viewModel.avatar)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Theme.accent, Theme.dimAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                )
                .overlay(alignment: .bottomTrailing) {
                    ZStack {
                        Circle()
                            .fill(Color(white: 0.1))
                            .frame(width: 28, height: 28)
                        Circle()
                            .stroke(Theme.dimAccent, lineWidth: 1)
                            .frame(width: 28, height: 28)
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.dimAccent)
                    }
                }
        }
    }

    // MARK: - Name

    private var nameSection: some View {
        Button {
            viewModel.beginEditingName()
        } label: {
            HStack(spacing: 6) {
                Text(viewModel.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                Image(systemName: "pencil")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.dimAccent)
            }
        }
    }

    // MARK: - Groups Section

    @ViewBuilder
    private var groupsSection: some View {
        let groups = pokerGroupService.groups

        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Groups", icon: "person.3.fill", iconColor: Theme.dimAccent)
                .padding(.horizontal, 20)

            if pokerGroupService.isLoadingGroups && groups.isEmpty {
                VStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { _ in
                        GroupRowSkeleton()
                    }
                }
                .padding(.horizontal, 20)
            } else if groups.isEmpty {
                EmptyGroupsView()
                    .padding(.horizontal, 20)
            } else {
                VStack(spacing: 2) {
                    ForEach(groups) { group in
                        NavigationLink(value: ProfileDestination.groupDetail(group)) {
                            GroupRowView(group: group)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Group Action Row

    private var groupActionRow: some View {
        HStack(spacing: 12) {
            Button { groupViewModel.showCreateSheet = true } label: {
                Text("Create Group")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            Button { groupViewModel.showJoinSheet = true } label: {
                Text("Join Group")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Section Header

    private func sectionHeader(title: String, icon: String, iconColor: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(iconColor)

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
                .tracking(0.5)
                .textCase(.uppercase)
        }
    }
}
