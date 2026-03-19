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
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Game Name")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)

                    InputField(text: $gameName, placeholder: "Game name")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Buy-In")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)

                    CurrencyInputField(value: $buyIn)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.secondary, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                }

                Button {
                    Task { await createGame() }
                } label: {
                    Group {
                        if isCreating {
                            ProgressView()
                        } else {
                            Text("Create Game")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(gameName.isEmpty || buyIn <= 0 || isCreating)
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.top, 16)
            .navigationTitle("Create Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
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
                buyIn: buyIn
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isCreating = false
    }
}
