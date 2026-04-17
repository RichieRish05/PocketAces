import SwiftUI

struct GameDetailView: View {
    let gameId: String

    @Environment(GameService.self) private var gameService
    @Environment(UserStore.self) private var userStore
    @Environment(PokerGroupService.self) private var groupService
    @Environment(\.dismiss) private var dismiss

    @State private var showCashOutSheet = false
    @State private var cashOutAmount = 0.0
    @State private var cashOutHasInput = false
    @State private var showCashOutConfirmation = false
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

    private var currentPlayerBuyIn: Double {
        guard let userId = currentUserId, let game = listenedGame else { return 0 }
        return game.players.first(where: { $0.playerId == userId })?.buyIn ?? 0
    }

    private var canCashOut: Bool {
        guard let userId = currentUserId, let game = listenedGame else { return false }
        return game.isActive && game.players.contains(where: { $0.playerId == userId && $0.isActive })
    }

    private var isLastActivePlayer: Bool {
        guard let game = listenedGame else { return false }
        let activePlayers = game.players.filter(\.isActive)
        return activePlayers.count == 1 && activePlayers.first?.playerId == currentUserId
    }

    private var suit: SuitIcon {
        guard let game = listenedGame else { return .from(gameId: gameId) }
        return .from(gameId: game.id ?? game.joinCode)
    }

    var body: some View {
        Group {
            if let game = listenedGame {
                ScrollView {
                    VStack(spacing: 20) {
                        potCard
                        playerList
                    }
                    .padding(.vertical, 16)
                }
                .navigationTitle(game.name)
                .safeAreaInset(edge: .bottom) {
                    if canCashOut {
                        actionBar
                    }
                }
            } else {
                ContentUnavailableView("Game Ended", systemImage: "xmark.circle", description: Text("This game is no longer active."))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                JoinCodeButton(joinCode: listenedGame?.joinCode ?? "")
            }
        }
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

    // MARK: - Pot Card

    private var potCard: some View {
        VStack(spacing: 8) {
            Text("Total Pot")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.dimAccent)

            Text(totalPot.formattedCurrency())
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())

            HStack(spacing: 6) {
                Image(systemName: "person.2.fill")
                    .font(.caption2)
                Text("\(listenedGame?.activePlayerCount ?? 0) active")
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(primaryBackground(cornerRadius: 20))
        .padding(.horizontal, 16)
    }

    // MARK: - Player List

    private var playerList: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Players", icon: "person.3.fill")

            VStack(spacing: 0) {
                ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                    playerRow(player)
                }
            }
            .padding(.vertical, 4)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.03))
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                }
            )
            .padding(.horizontal, 16)
        }
    }

    private func playerRow(_ player: Player) -> some View {
        let isCurrentUser = player.playerId == currentUserId

        return HStack(spacing: 12) {
            // Avatar with active indicator
            ZStack(alignment: .bottomTrailing) {
                Image(player.avatarName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                if player.isActive {
                    Circle()
                        .fill(Theme.win)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: 1.5)
                        )
                        .offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(player.name ?? "Player")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white)

                    if isCurrentUser {
                        Text("You")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Theme.primaryDark)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Theme.accent.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                }

                Text("\(player.buyIn.formattedCurrency()) invested")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            if !player.isActive {
                let profit = player.cashOut - player.buyIn
                VStack(alignment: .trailing, spacing: 3) {
                    Text(player.cashOut.formattedCurrency())
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.8))

                    Text(profit.formattedCurrency(decimals: 2, showSign: true))
                        .font(.caption.weight(.bold).monospacedDigit())
                        .foregroundStyle(profit >= 0 ? Theme.win : Theme.loss)
                }
            } else {
                Text("Playing")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.win.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                rebuyAmount = 0
                showRebuySheet = true
            } label: {
                Text("Re-buy")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Theme.accent.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {
                cashOutAmount = 0
                cashOutHasInput = false
                showCashOutSheet = true
            } label: {
                Text("Cash Out")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Cash Out Sheet

    private var cashOutSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if showCashOutConfirmation {
                    cashOutConfirmationContent
                } else {
                    cashOutInputContent
                }
            }
            .navigationTitle("Cash Out")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(showCashOutConfirmation ? "Back" : "Cancel") {
                        if showCashOutConfirmation {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showCashOutConfirmation = false
                            }
                        } else {
                            showCashOutSheet = false
                        }
                    }
                    .foregroundStyle(Theme.dimAccent)
                }
            }
        }
        .presentationDetents([.medium])
        .onDisappear {
            showCashOutConfirmation = false
        }
    }

    private var cashOutInputContent: some View {
        Group {
            Text("Enter your chip total")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 8)

            CurrencyInputField(value: $cashOutAmount, hasInput: $cashOutHasInput)
                .padding(.horizontal, 16)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showCashOutConfirmation = true
                }
            } label: {
                Text("Cash Out")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(!cashOutHasInput || cashOutAmount > totalPot ? Theme.accent.opacity(0.4) : Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!cashOutHasInput || cashOutAmount > totalPot)
            .padding(.horizontal, 16)

            Text("Remaining pot: \(totalPot.formattedCurrency())")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.35))

            Spacer()
        }
    }

    private var cashOutConfirmationContent: some View {
        let profit = cashOutAmount - currentPlayerBuyIn

        return Group {
            Text("Confirm your cash out")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 8)

            VStack(spacing: 0) {
                cashOutSummaryRow(label: "Buy In", value: currentPlayerBuyIn.formattedCurrency(), color: .white)
                Divider().background(Color.white.opacity(0.08))
                cashOutSummaryRow(label: "Cash Out", value: cashOutAmount.formattedCurrency(), color: .white)
                Divider().background(Color.white.opacity(0.08))
                cashOutSummaryRow(
                    label: "Profit",
                    value: profit.formattedCurrency(decimals: 2, showSign: true),
                    color: profit >= 0 ? Theme.win : Theme.loss
                )
            }
            .padding(.vertical, 4)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.03))
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                }
            )
            .padding(.horizontal, 16)

            Button {
                Task { await cashOut() }
            } label: {
                Group {
                    if isCashingOut {
                        ProgressView()
                            .tint(Color(red: 0.12, green: 0.10, blue: 0.06))
                    } else {
                        Text("Confirm Cash Out")
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isCashingOut ? Theme.accent.opacity(0.4) : Theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isCashingOut)
            .padding(.horizontal, 16)

            Spacer()
        }
    }

    private func cashOutSummaryRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Re-buy Sheet

    private var rebuySheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter re-buy amount")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)

                CurrencyInputField(value: $rebuyAmount)
                    .padding(.horizontal, 16)

                Button {
                    Task { await performRebuy() }
                } label: {
                    Group {
                        if isRebuying {
                            ProgressView()
                                .tint(Color(red: 0.12, green: 0.10, blue: 0.06))
                        } else {
                            Text("Confirm Re-buy")
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isRebuying || rebuyAmount <= 0 ? Theme.accent.opacity(0.4) : Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
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
                    .foregroundStyle(Theme.dimAccent)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(Theme.dimAccent)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))
                .tracking(0.5)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 16)
    }

    private func primaryBackground(cornerRadius: CGFloat) -> some View {
        ZStack {
            Theme.gradient

            RadialGradient(
                colors: [Color.mint.opacity(0.08), Color.clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 200
            )

            RadialGradient(
                colors: [Color.cyan.opacity(0.06), Color.clear],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 180
            )

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    Theme.borderGradient,
                    lineWidth: 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
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
        let groupId = listenedGame?.groupId
        isCashingOut = true
        do {
            let result = try await gameService.cashOut(gameId: gameId, userId: userId, cashOut: cashOutAmount)
            try await userStore.applyCashOut(buyIn: result.buyIn, cashOut: cashOutAmount)

            if let groupId {
                do {
                    try await groupService.updateMemberStats(
                        groupId: groupId,
                        userId: userId,
                        buyIn: result.buyIn,
                        cashOut: cashOutAmount,
                        gameId: gameId,
                        gameEnded: result.gameEnded,
                        avatarName: userStore.userData?.avatarName ?? "avatar_01"
                    )
                } catch {
                    // Group stats failure should not block cash-out
                }
            }

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
