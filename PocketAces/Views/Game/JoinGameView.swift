import SwiftUI

struct JoinGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameService.self) private var gameService
    @Environment(UserStore.self) private var userStore

    @State private var joinCode = ""
    @State private var isJoining = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter the 6-character room code to join a game.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                TextField("Room Code", text: $joinCode)
                    .textFieldStyle(.plain)
                    .font(.title2)
                    .monospaced()
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.secondary, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .onChange(of: joinCode) { _, newValue in
                        joinCode = String(newValue.prefix(6)).uppercased()
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
                        } else {
                            Text("Join Game")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(joinCode.count < 6 || isJoining)
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.top, 16)
            .navigationTitle("Join Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
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
            buyIn: 0,
            cashOut: 0,
            isActive: true
        )

        do {
            _ = try await gameService.joinGame(joinCode: joinCode, player: player, buyIn: 0)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isJoining = false
    }
}
