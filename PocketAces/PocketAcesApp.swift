import SwiftUI

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct PocketAcesApp: App {
    @State private var authService: AuthService
    @State private var gameService: GameService
    @State private var userStore = UserStore()

    init() {
        FirebaseApp.configure()
        _authService = State(initialValue: AuthService())
        _gameService = State(initialValue: GameService())
        userStore.clear()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isCheckingAuth || (authService.currentUserId != nil && (userStore.userData == nil)) {
                    ProgressView()
                } else if authService.currentUserId != nil && userStore.userData != nil {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environment(authService)
            .environment(userStore)
            .environment(gameService)
            .task {
                if let userId = authService.currentUserId {
                    try? await userStore.fetchUser(userId: userId)
                    gameService.listenToActiveGames(userId: userId)
                    try? await gameService.fetchPastGames(userId: userId)
                }
            }
            .onChange(of: authService.currentUserId) { _, newId in
                if let userId = newId {
                    Task {
                        try? await userStore.fetchUser(userId: userId)
                        gameService.listenToActiveGames(userId: userId)
                        try? await gameService.fetchPastGames(userId: userId)
                    }
                } else {
                    gameService.stopListeningToActiveGames()
                }
            }
        }
    }
}
