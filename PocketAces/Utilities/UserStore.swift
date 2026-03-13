import Foundation
import FirebaseFirestore

@Observable
final class UserStore {
    private(set) var userData: UserData?

    private let key = "userData"
    private var listener: ListenerRegistration?

    init() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        userData = try? JSONDecoder().decode(UserData.self, from: data)
    }

    deinit {
        stopListening()
    }

    func save(_ userData: UserData) {
        let data = try? JSONEncoder().encode(userData)
        UserDefaults.standard.set(data, forKey: key)
        self.userData = userData
    }

    func clear() {
        stopListening()
        UserDefaults.standard.removeObject(forKey: key)
        userData = nil
    }

    func startListening(userId: String) {
        stopListening()
        let docRef = Firestore.firestore().collection("users").document(userId)
        listener = docRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self, let snapshot, snapshot.exists else { return }
            if let decoded = try? snapshot.data(as: UserData.self) {
                self.save(decoded)
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
