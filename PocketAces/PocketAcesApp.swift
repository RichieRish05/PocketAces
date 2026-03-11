import SwiftUI

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct PocketAcesApp: App {
    @State private var authService: AuthService
    @State private var profileStore = UserProfileStore()

    init() {
        FirebaseApp.configure()
        _authService = State(initialValue: AuthService())
        profileStore.clear() // For debugging
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isCheckingAuth {
                    ProgressView()
                } else if authService.currentUserId != nil && profileStore.profile != nil {
                    HomeView()
                } else {
                    OnboardingView(authService: authService)
                }
            }
            .environment(authService)
            .environment(profileStore)
        }
    }
}
