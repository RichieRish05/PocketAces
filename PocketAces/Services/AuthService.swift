import Foundation
import FirebaseAuth
import FirebaseFirestore

@Observable
final class AuthService {
    private(set) var currentUserId: String?
    private(set) var isCheckingAuth = true

    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Add a listener to check if user is signed in
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUserId = user?.uid
            self?.isCheckingAuth = false
        }
    }

    deinit {
        // Clean up listener
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    @discardableResult
    func signInAnonymously(_ displayName: String, _ avatarName: String) async throws -> UserData {
        // Start or resume an anonymous session
        let result = try await Auth.auth().signInAnonymously()
        let uid = result.user.uid
        currentUserId = uid

        // Check if user is already in db
        let docRef = Firestore.firestore().collection("users").document(uid)
        let snapshot = try await docRef.getDocument()

        if snapshot.exists {
            print("Exiting Early")
            return try snapshot.data(as: UserData.self)
        }

        let userData = UserData(
            id: uid,
            displayName: displayName,
            avatarName: avatarName,
            gamesPlayed: 0,
            totalBuyIn: 0,
            totalCashOut: 0,
            netProfit: 0,
            sumProfitSquared: 0,
            wins: 0,
            biggestWin: 0,
            biggestLoss: 0,
            currentWinStreak: 0,
            currentLossStreak: 0,
            longestWinStreak: 0,
            longestLossStreak: 0,
            recentResults: [],
            createdAt: Date(),
            gems: 0,
            themeName: "classic"
        )

        // Insert new user
        try docRef.setData(from: userData)
        print("Inserted New User")
        return userData
    }
}
