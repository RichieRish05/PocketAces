import SwiftUI

struct CreateGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameService.self) private var gameService
    @Environment(UserStore.self) private var userStore

    @State private var gameName: String = ""
    @State private var buyIn = 0.0
    @State private var isCreating = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Set up your poker game")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Game Name")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(.horizontal, 16)

                    TextField("Game name", text: $gameName)
                        .font(.title2)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Theme.accent.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Buy-In")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(.horizontal, 16)

                    CurrencyInputField(value: $buyIn)
                        .padding(.horizontal, 16)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await createGame() }
                } label: {
                    Group {
                        if isCreating {
                            ProgressView()
                                .tint(Color(red: 0.12, green: 0.10, blue: 0.06))
                        } else {
                            Text("Create Game")
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(gameName.isEmpty || buyIn <= 0 || isCreating ? Theme.accent.opacity(0.4) : Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(gameName.isEmpty || buyIn <= 0 || isCreating)
                .padding(.horizontal, 16)

                Spacer()
            }
            .navigationTitle("Create Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.dimAccent)
                }
            }
        }
    }

    private func createGame() async {
        guard let userId = userStore.userData?.id else { return }

        isCreating = true
        errorMessage = nil

        do {
            _ = try await gameService.createGame(
                name: gameName,
                hostId: userId,
                hostDisplayName: userStore.userData?.displayName ?? "Host",
                buyIn: buyIn,
                avatarName: userStore.userData?.avatarName ?? "avatar_01"
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isCreating = false
    }
}
