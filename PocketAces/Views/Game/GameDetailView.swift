import SwiftUI

struct GameDetailView: View {
    let game: Game

    @Environment(GameService.self) private var gameService
    @Environment(UserStore.self) private var userStore
    @Environment(\.dismiss) private var dismiss

    @State private var showCashOutSheet = false
    @State private var cashOutAmount = 0.0
    @State private var isCashingOut = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showEndGameWarning = false

    // MARK: - Computed Properties

    private var listenedGame: Game { gameService.listenedGame ?? game }
    private var players: [Player] { listenedGame.players }
    private var totalPot: Double { listenedGame.totalPot }
    private var currentUserId: String? { userStore.userData?.id }

    private var canCashOut: Bool {
        guard let userId = currentUserId else { return false }
        return listenedGame.isActive && listenedGame.players.contains(where: { $0.playerId == userId && $0.isActive })
    }

    private var isLastActivePlayer: Bool {
        let activePlayers = listenedGame.players.filter(\.isActive)
        return activePlayers.count == 1 && activePlayers.first?.playerId == currentUserId
    }

    private var cardGradient: CardGradient {
        .from(gameId: listenedGame.id ?? listenedGame.joinCode)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                potCard
                playerList
            }
            .padding(.vertical, 16)
        }
        .navigationTitle(listenedGame.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if canCashOut {
                cashOutButton
            }
        }
        .sheet(isPresented: $showCashOutSheet) {
            cashOutSheet
        }
        .alert("End Game", isPresented: $showEndGameWarning) {
            Button("Cancel", role: .cancel) {}
            Button("Cash Out & End Game", role: .destructive) {
                Task { await performCashOut() }
            }
        } message: {
            Text("You're the last active player. Cashing out will end the game permanently.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "Something went wrong.")
        }
        .task { gameService.listenToGame(gameId: game.id ?? "") }
        .onDisappear { gameService.stopListening() }
        .onChange(of: listenedGame.isActive) { _, isActive in
            if !isActive { dismiss() }
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(listenedGame.name)
                    .font(.title2.bold())

                Text("\(listenedGame.activePlayerCount) players")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(listenedGame.joinCode)
                .font(.subheadline.monospaced())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Pot

    private var potCard: some View {
        VStack(spacing: 6) {
            Text("Total Pot")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(totalPot, format: .currency(code: "USD"))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: cardGradient.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 16)
    }

    // MARK: - Player List

    private var playerList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Players")
                .font(.headline)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                    playerRow(player)

                    if index < players.count - 1 {
                        Divider()
                            .padding(.leading, 64)
                    }
                }
            }
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    private func playerRow(_ player: Player) -> some View {
        HStack(spacing: 12) {
            Image(player.avatarName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name ?? "Player")
                    .font(.body.weight(.medium))

                Text("Buy-in: \(player.buyIn, format: .currency(code: "USD"))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !player.isActive {
                let profit = player.cashOut - player.buyIn
                VStack(alignment: .trailing, spacing: 2) {
                    Text(player.cashOut, format: .currency(code: "USD"))
                        .font(.subheadline.weight(.semibold))
                    Text(profit >= 0 ? "+\(profit, specifier: "%.2f")" : "\(profit, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundStyle(profit >= 0 ? .green : .red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .opacity(player.isActive ? 1 : 0.5)
    }

    // MARK: - Cash Out

    private var cashOutButton: some View {
        Button {
            cashOutAmount = 0
            showCashOutSheet = true
        } label: {
            Text("Cash Out")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var cashOutSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter your chip total")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                CurrencyInputField(value: $cashOutAmount)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.secondary, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)

                Button {
                    Task { await cashOut() }
                } label: {
                    Group {
                        if isCashingOut {
                            ProgressView()
                        } else {
                            Text("Confirm Cash Out")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isCashingOut || cashOutAmount <= 0 || cashOutAmount > totalPot)
                .padding(.horizontal, 16)

                Text("Remaining pot: \(totalPot, format: .currency(code: "USD"))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .navigationTitle("Cash Out")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showCashOutSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Actions

    private func cashOut() async {
        if isLastActivePlayer {
            showEndGameWarning = true
            return
        }
        await performCashOut()
    }

    private func performCashOut() async {
        guard let userId = currentUserId, let gameId = listenedGame.id else { return }
        isCashingOut = true
        do {
            let playerBuyIn = try await gameService.cashOut(gameId: gameId, userId: userId, cashOut: cashOutAmount)
            try await userStore.applyCashOut(buyIn: playerBuyIn, cashOut: cashOutAmount)
            showCashOutSheet = false
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isCashingOut = false
    }
}
