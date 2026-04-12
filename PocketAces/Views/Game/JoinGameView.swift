import SwiftUI

struct JoinGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameService.self) private var gameService
    @Environment(UserStore.self) private var userStore
    @Environment(PokerGroupService.self) private var pokerGroupService

    @State private var joinCode = ""
    @State private var buyIn = 0.0
    @State private var isJoining = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter the 6-character room code")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)

                TextField("Room Code", text: $joinCode)
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
                    .onChange(of: joinCode) { _, newValue in
                        joinCode = String(newValue.prefix(6)).uppercased()
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
                    Task { await joinGame() }
                } label: {
                    Group {
                        if isJoining {
                            ProgressView()
                                .tint(Color(red: 0.12, green: 0.10, blue: 0.06))
                        } else {
                            Text("Join Game")
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(joinCode.count < 6 || buyIn <= 0 || isJoining ? Theme.accent.opacity(0.4) : Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(joinCode.count < 6 || buyIn <= 0 || isJoining)
                .padding(.horizontal, 16)

                Spacer()
            }
            .navigationTitle("Join Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.dimAccent)
                }
            }
        }
    }

    private func joinGame() async {
        guard let userId = userStore.userData?.id else { return }

        isJoining = true
        errorMessage = nil

        let player = Player(
            playerId: userId,
            name: userStore.userData?.displayName ?? "Player",
            avatarName: userStore.userData?.avatarName ?? "avatar_01",
            buyIn: buyIn,
            cashOut: 0,
            isActive: true
        )

        do {
            let userGroupIds = pokerGroupService.groups.compactMap(\.id)
            _ = try await gameService.joinGame(joinCode: joinCode, player: player, buyIn: buyIn, userGroupIds: userGroupIds)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isJoining = false
    }
}
