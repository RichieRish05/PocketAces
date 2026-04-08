import Foundation
import SwiftUI

@Observable
final class ProfileViewModel {
    private(set) var userData: UserData?
    private var userStore: UserStore?

    var navigationPath = NavigationPath()
    var showNameEditor = false
    var draftName = ""
    var selectedAvatar: String?
    var errorMessage: String?

    var name: String { userData?.displayName ?? "Player" }
    var avatar: String { userData?.avatarName ?? "avatar_01" }

    var memberSinceText: String {
        guard let date = userData?.createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Member since \(formatter.string(from: date))"
    }

    func load(from userStore: UserStore) {
        self.userStore = userStore
        self.userData = userStore.userData
    }

    func beginEditingName() {
        draftName = name
        showNameEditor = true
    }

    func saveName() async {
        let trimmed = draftName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        do {
            try await userStore?.updateDisplayName(trimmed)
            userData = userStore?.userData
            showNameEditor = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func beginPickingAvatar() {
        selectedAvatar = avatar
        navigationPath.append(ProfileDestination.avatarPicker)
    }

    func beginPickingTheme() {
        navigationPath.append(ProfileDestination.themePicker)
    }

    func openGroups() {
        navigationPath.append(ProfileDestination.groups)
    }

    func saveTheme(_ package: ThemePackage) async {
        Theme.shared.apply(package)
        do {
            try await userStore?.updateTheme(package.rawValue)
        } catch {
            errorMessage = error.localizedDescription
        }
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func saveAvatar() async {
        guard let selected = selectedAvatar else { return }
        do {
            try await userStore?.updateAvatar(selected)
            userData = userStore?.userData
            if !navigationPath.isEmpty {
                navigationPath.removeLast()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
