import SwiftUI

@Observable
final class OnboardingViewModel {
    var showNameEntry: Bool = false
    var selectedAvatar: String?
    var displayName: String = ""
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored var profileStore: UserProfileStore?
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    var canProceedToName: Bool {
        selectedAvatar != nil
    }

    var canFinish: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func goToNameEntry() {
        showNameEntry = true
    }

    func finish() async {
        guard let avatar = selectedAvatar, canFinish else { return }

        isLoading = true
        errorMessage = nil

        do {
            let profile = UserProfile(
                displayName: displayName.trimmingCharacters(in: .whitespaces),
                avatarName: avatar
            )
            profileStore?.save(profile)
            try await authService.signInAnonymously()
            print("Saved user profile " + profile.displayName)
        } catch {
            profileStore?.clear()
            print(error)
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
