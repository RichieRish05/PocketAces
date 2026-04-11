import SwiftUI

struct GroupsView: View {
    @Environment(UserStore.self) private var userStore
    @Environment(PokerGroupService.self) private var groupService
    @State private var viewModel = GroupViewModel()
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    groupsListSection
                }
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)

            actionRow
        }
        .background(Color.black)
        .navigationTitle("Groups")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load(from: userStore, groupService: groupService)
        }
        .sheet(isPresented: $viewModel.showJoinSheet) {
            joinGroupSheet
        }
        .sheet(isPresented: $viewModel.showCreateSheet) {
            createGroupSheet
        }
    }


    // MARK: - Groups List

    @ViewBuilder
    private var groupsListSection: some View {
        if viewModel.isLoading {
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    groupSkeleton
                }
            }
            .padding(.horizontal, 16)
        } else {
            VStack(spacing: 12) {
                ForEach(viewModel.groups) { group in
                    NavigationLink(value: ProfileDestination.groupDetail(group)) {
                        GroupCardView(group: group)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var groupSkeleton: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(0.04))
            .frame(height: 60)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            )
            .redacted(reason: .placeholder)
    }



    // MARK: - Action Row

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button { viewModel.showCreateSheet = true } label: {
                Text("Create Group")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            Button { viewModel.showJoinSheet = true } label: {
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
        .padding(.bottom, 32)
        .background(
            LinearGradient(
                colors: [.black.opacity(0), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80)
            .allowsHitTesting(false),
            alignment: .top
        )
    }

    // MARK: - Join Group Sheet

    private var joinGroupSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter the group's join code")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)

                TextField("Join Code", text: $viewModel.joinCode)
                    .textFieldStyle(.plain)
                    .font(.title2)
                    .monospaced()
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Theme.accent.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .onChange(of: viewModel.joinCode) { _, newValue in
                        viewModel.joinCode = String(newValue.prefix(6)).uppercased()
                    }

                if let joinError = viewModel.joinErrorMessage {
                    Text(joinError)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await viewModel.joinGroup() }
                } label: {
                    Group {
                        if viewModel.isJoining {
                            ProgressView()
                                .tint(Color(red: 0.12, green: 0.10, blue: 0.06))
                        } else {
                            Text("Join Group")
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.joinCode.count < 6 || viewModel.isJoining ? Theme.accent.opacity(0.4) : Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.joinCode.count < 6 || viewModel.isJoining)
                .padding(.horizontal, 16)

                Spacer()
            }
            .navigationTitle("Join Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showJoinSheet = false }
                        .foregroundStyle(Theme.dimAccent)
                }
            }
        }
    }

    // MARK: - Create Group Sheet

    private var createGroupSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Give your group a name")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)

                InputField(text: $viewModel.newGroupName, placeholder: "Group Name")

                if let createError = viewModel.createErrorMessage {
                    Text(createError)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await viewModel.createGroup() }
                } label: {
                    Group {
                        if viewModel.isCreating {
                            ProgressView()
                                .tint(Color(red: 0.12, green: 0.10, blue: 0.06))
                        } else {
                            Text("Create Group")
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.newGroupName.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isCreating ? Theme.accent.opacity(0.4) : Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.newGroupName.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isCreating)
                .padding(.horizontal, 16)

                Spacer()
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showCreateSheet = false }
                        .foregroundStyle(Theme.dimAccent)
                }
            }
        }
    }
}
