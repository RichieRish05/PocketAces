import SwiftUI

struct ProfileView: View {
    @Environment(Theme.self) private var theme
    @Environment(UserStore.self) private var userStore
    @State private var viewModel = ProfileViewModel()
    @State private var appeared = false

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        GemBadge()
                    }
                    profileCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                viewModel.load(from: userStore)
                withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                    appeared = true
                }
            }
            .navigationDestination(for: ProfileDestination.self) { destination in
                switch destination {
                case .avatarPicker:
                    AvatarPickerView(viewModel: viewModel)
                case .themePicker:
                    ThemePickerView(viewModel: viewModel)
                }
            }
            .sheet(isPresented: $viewModel.showNameEditor) {
                nameEditorSheet
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
            avatarSection
            nameSection
            if !viewModel.memberSinceText.isEmpty {
                Text(viewModel.memberSinceText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(white: 0.45))
            }
            themeButton
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
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
                                colors: [theme.accent, theme.dimAccent],
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
                            .stroke(theme.dimAccent, lineWidth: 1)
                            .frame(width: 28, height: 28)
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.dimAccent)
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
                    .foregroundStyle(theme.dimAccent)
            }
        }
    }

    // MARK: - Theme Button

    private var themeButton: some View {
        Button {
            viewModel.beginPickingTheme()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "paintpalette")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.accent)
                Text("Theme")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text(theme.currentPackage.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(white: 0.45))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(white: 0.35))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.1))
            )
        }
    }

    // MARK: - Name Editor Sheet

    private var nameEditorSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                InputField(text: $viewModel.draftName, placeholder: "Display Name")
                    .font(.system(size: 20))
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .autocorrectionDisabled()

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showNameEditor = false }
                        .foregroundStyle(theme.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await viewModel.saveName() }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.accent)
                    .disabled(viewModel.draftName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
