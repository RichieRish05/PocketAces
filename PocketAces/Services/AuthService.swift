import Foundation
import FirebaseAuth

@Observable
final class AuthService {
    private(set) var currentUserId: String?
    private(set) var isCheckingAuth = true

    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUserId = user?.uid
            self?.isCheckingAuth = false
        }
    }

    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signInAnonymously() async throws {
        let result = try await Auth.auth().signInAnonymously()
        currentUserId = result.user.uid
    }
}
