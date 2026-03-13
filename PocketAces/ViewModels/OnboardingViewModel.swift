import SwiftUI

@Observable
final class OnboardingViewModel {
    var showNameEntry: Bool = false
    var selectedAvatar: String?
    var displayName: String = ""
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored var authService: AuthService?
    @ObservationIgnored var userStore: UserStore?

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
            let trimmedName = displayName.trimmingCharacters(in: .whitespaces)
            let userData = try await authService?.signInAnonymously(trimmedName, avatar)
            if let userData {
                userStore?.save(userData)
            }
        } catch {
            userStore?.clear()
            print(error)
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
