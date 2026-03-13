import SwiftUI

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct PocketAcesApp: App {
    @State private var authService: AuthService
    @State private var userStore = UserStore()

    init() {
        FirebaseApp.configure()
        _authService = State(initialValue: AuthService())
        userStore.clear()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isCheckingAuth || (authService.currentUserId != nil && userStore.userData == nil) {
                    ProgressView()
                } else if authService.currentUserId != nil && userStore.userData != nil {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environment(authService)
            .environment(userStore)
            .onChange(of: authService.currentUserId) { _, newId in
                if let userId = newId {
                    userStore.startListening(userId: userId)
                } else {
                    userStore.stopListening()
                }
            }
        }
    }
}
