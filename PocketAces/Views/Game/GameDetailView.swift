import SwiftUI

struct GameDetailView: View {
    let gameId: String

    @Environment(GameService.self) private var gameService
    @Environment(UserStore.self) private var userStore
    @Environment(\.dismiss) private var dismiss

    @State private var showCashOutSheet = false
    @State private var cashOutAmount = 0.0
    @State private var isCashingOut = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showEndGameWarning = false
    @State private var showRebuySheet = false
    @State private var rebuyAmount = 0.0
    @State private var isRebuying = false

    // MARK: - Computed Properties

    private var listenedGame: Game? {
        gameService.activeGames.first(where: { $0.id == gameId })
    }
    private var players: [Player] { listenedGame?.players ?? [] }
    private var totalPot: Double { listenedGame?.totalPot ?? 0 }
    private var currentUserId: String? { userStore.userData?.id }

    private var canCashOut: Bool {
        guard let userId = currentUserId, let game = listenedGame else { return false }
        return game.isActive && game.players.contains(where: { $0.playerId == userId && $0.isActive })
    }

    private var isLastActivePlayer: Bool {
        guard let game = listenedGame else { return false }
        let activePlayers = game.players.filter(\.isActive)
        return activePlayers.count == 1 && activePlayers.first?.playerId == currentUserId
    }

    private var cardGradient: CardGradient {
        guard let game = listenedGame else { return .from(gameId: gameId) }
        return .from(gameId: game.id ?? game.joinCode)
    }

    var body: some View {
        Group {
            if let game = listenedGame {
                ScrollView {
                    VStack(spacing: 20) {
                        headerCard
                        potCard
                        playerList
                    }
                    .padding(.vertical, 16)
                }
                .navigationTitle(game.name)
                .safeAreaInset(edge: .bottom) {
                    if canCashOut {
                        HStack(spacing: 12) {
                            Button {
                                rebuyAmount = 0
                                showRebuySheet = true
                            } label: {
                                Text("Re-buy")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                            .buttonStyle(.bordered)

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
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }
            } else {
                ContentUnavailableView("Game Ended", systemImage: "xmark.circle", description: Text("This game is no longer active."))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCashOutSheet) {
            cashOutSheet
        }
        .sheet(isPresented: $showRebuySheet) {
            rebuySheet
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
        .onChange(of: listenedGame == nil) { _, isNil in
            if isNil { dismiss() }
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(listenedGame?.name ?? "")
                    .font(.title2.bold())

                Text("\(listenedGame?.activePlayerCount ?? 0) players")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(listenedGame?.joinCode ?? "")
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

    // MARK: - Re-buy

    private var rebuySheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter re-buy amount")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                CurrencyInputField(value: $rebuyAmount)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.secondary, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)

                Button {
                    Task { await performRebuy() }
                } label: {
                    Group {
                        if isRebuying {
                            ProgressView()
                        } else {
                            Text("Confirm Re-buy")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRebuying || rebuyAmount <= 0)
                .padding(.horizontal, 16)

                Spacer()
            }
            .navigationTitle("Re-buy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showRebuySheet = false
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
        guard let userId = currentUserId, let gameId = listenedGame?.id else { return }
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

    private func performRebuy() async {
        guard let userId = currentUserId, let gameId = listenedGame?.id else { return }
        isRebuying = true
        do {
            try await gameService.rebuy(gameId: gameId, userId: userId, buyIn: rebuyAmount)
            showRebuySheet = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isRebuying = false
    }
}
