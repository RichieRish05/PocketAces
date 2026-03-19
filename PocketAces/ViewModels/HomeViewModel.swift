import Foundation

@Observable
final class HomeViewModel {
    var showCreateGame = false
    var showJoinGame = false
    var errorMessage: String?
    var showError = false

    private let gameService: GameService
    private let userStore: UserStore

    init(gameService: GameService, userStore: UserStore) {
        self.gameService = gameService
        self.userStore = userStore
    }

    var displayName: String {
        userStore.userData?.displayName ?? "Player"
    }

    var avatarName: String {
        userStore.userData?.avatarName ?? Avatar.all.first ?? "avatar_01"
    }

    var userId: String? {
        userStore.userData?.id
    }

    var activeGames: [Game] {
        gameService.activeGames
    }


    var allGames: [Game] {
        activeGames
    }

    var isLoading: Bool {
        gameService.isLoadingGames
    }

    func refresh() async {
        guard let userId else { return }
        do {
            try await gameService.fetchGames(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func joinGame(code: String) async throws -> Game {
        guard let userId else {
            throw GameServiceError.gameNotFound
        }
        let player = Player(
            playerId: userId,
            name: displayName,
            buyIn: 0,
            cashOut: 0,
            isActive: true
        )
        return try await gameService.joinGame(joinCode: code, player: player, buyIn: 0)
    }
}
