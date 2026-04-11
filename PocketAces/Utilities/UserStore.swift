import Foundation
import FirebaseFirestore

@Observable
final class UserStore {
    private(set) var userData: UserData?

    private let key = "userData"

    init() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        userData = try? JSONDecoder().decode(UserData.self, from: data)
    }

    func save(_ userData: UserData) {
        let data = try? JSONEncoder().encode(userData)
        UserDefaults.standard.set(data, forKey: key)
        self.userData = userData
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
        userData = nil
    }

    /// One-time fetch of user data from Firestore. Used on app launch to hydrate
    /// local state.
    func fetchUser(userId: String) async throws {
        let snapshot = try await Firestore.firestore()
            .collection("users").document(userId).getDocument()
        guard snapshot.exists, let decoded = try? snapshot.data(as: UserData.self) else { return }
        save(decoded)
    }

    /// Update display name locally and in Firestore.
    func updateDisplayName(_ newName: String) async throws {
        guard var updated = userData else { return }
        updated.displayName = newName
        save(updated)

        try await Firestore.firestore()
            .collection("users").document(updated.id)
            .updateData(["displayName": newName])
    }

    /// Update avatar locally and in Firestore.
    func updateAvatar(_ newAvatar: String) async throws {
        guard var updated = userData else { return }
        updated.avatarName = newAvatar
        save(updated)

        try await Firestore.firestore()
            .collection("users").document(updated.id)
            .updateData(["avatarName": newAvatar])
    }

    ///Optimistic stats update on cash-out.
    ///Computes new stats locally (instant UI update via `save`)
    ///2. Writes to Firestore (best-effort — local update stands even if this fails)
    func applyCashOut(buyIn: Double, cashOut: Double) async throws {
        guard var updated = userData else { return }
        updated.applyCashOut(buyIn: buyIn, cashOut: cashOut)
        save(updated)

        try await Firestore.firestore()
            .collection("users").document(updated.id)
            .setData(from: updated)
    }
}
