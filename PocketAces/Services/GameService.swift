import Foundation
import FirebaseFirestore

enum GameServiceError: LocalizedError {
    case gameNotFound
    case playerAlreadyInGame
    case playerNotInGame
    case joinCodeGenerationFailed
    case networkError
    case cashOutExceedsPot
    case gameNotActive
    case playerNotActive

    var errorDescription: String? {
        switch self {
        case .gameNotFound: "Game not found."
        case .playerAlreadyInGame: "You're already in this game."
        case .playerNotInGame: "Player not found in this game."
        case .joinCodeGenerationFailed: "Failed to generate a unique join code. Please try again."
        case .networkError: "An unexpected network error occurred."
        case .cashOutExceedsPot: "Cash-out amount exceeds the remaining pot."
        case .gameNotActive: "This game is no longer active."
        case .playerNotActive: "You have already cashed out."
        
        }
    }
}

/// Service that manages game CRUD operations against Firestore.
/// `activeGames` is kept in sync via a persistent query snapshot listener.
@Observable
final class GameService {
    private(set) var activeGames: [Game] = []
    private(set) var isLoadingGames = false

    private var activeGamesListener: ListenerRegistration?

    private(set) var pastGames: [Game] = [] // Past games user was involved in
    private(set) var isLoadingPastGames = false // Used to indicate document fetching in progress
    private(set) var hasMorePastGames = true // Used for pagination logic
    private var lastPastGameDocument: DocumentSnapshot? // DB result
    private let pastGamesPageSize = 10 // Size of page for pagination

    private let db = Firestore.firestore()

    private static let joinCodeCharset = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
    private static let joinCodeLength = 6

    // MARK: - Public

    /// Attaches a persistent snapshot listener on active games for the given user.
    /// Replaces `activeGames` on every snapshot, keeping HomeView in sync in real time.
    func listenToActiveGames(userId: String) {
        stopListeningToActiveGames()
        isLoadingGames = true

        activeGamesListener = db.collection("games")
            .whereField("playerIds", arrayContains: userId)
            .whereField("isActive", isEqualTo: true)
            .order(by: "startedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoadingGames = false
                guard let snapshot else { return }
                // Detect games that just ended - re-fetch past games with correct data
                if snapshot.documentChanges.contains(where: { $0.type == .removed }) {
                    Task { try? await self.fetchPastGames(userId: userId) }
                }
                self.activeGames = snapshot.documents.compactMap { try? $0.data(as: Game.self) }
            }
    }

    /// Removes the active-games query listener.
    func stopListeningToActiveGames() {
        activeGamesListener?.remove()
        activeGamesListener = nil
    }

    /// Creates a new game document in Firestore with the host as the first player.
    /// Returns the created `Game` with its Firestore document ID set.
    func createGame(name: String, hostId: String, hostDisplayName: String, buyIn: Double, avatarName: String = "avatar_01") async throws -> Game {

        let joinCode = try await generateJoinCode()

        let host = Player(
            playerId: hostId,
            name: hostDisplayName,
            avatarName: avatarName,
            buyIn: buyIn,
            cashOut: 0,
            isActive: true
        )

        let game = Game(
            name: name,
            hostDisplayName: hostDisplayName,
            hostId: hostId,
            joinCode: joinCode,
            joinCodeEnabled: true,
            playerCount: 1,
            activePlayerCount: 1,
            players: [host],
            playerIds: [hostId],
            isActive: true,
            startedAt: Date(),
            totalPot: buyIn
        )

        let docRef = try db.collection("games").addDocument(from: game)
        var createdGame = game
        createdGame.id = docRef.documentID
        return createdGame
    }

    /// Looks up an active game by join code and adds the player via a Firestore transaction.
    /// Throws `gameNotFound` if no active game matches or `playerAlreadyInGame` on duplicates.
    func joinGame(joinCode: String, player: Player, buyIn: Double) async throws -> Game {
        let snapshot: QuerySnapshot
        do {
            snapshot = try await db.collection("games")
                .whereField("joinCode", isEqualTo: joinCode.uppercased())
                .whereField("isActive", isEqualTo: true)
                .getDocuments()
        } catch {
            throw GameServiceError.networkError
        }

        guard let document = snapshot.documents.first else {
            throw GameServiceError.gameNotFound
        }

        let gameRef = document.reference

        let joinedGame: Game
        do {
            joinedGame = try await db.runTransaction { transaction, errorPointer in
            let freshSnapshot: DocumentSnapshot
            do {
                freshSnapshot = try transaction.getDocument(gameRef)
            } catch let error as NSError {
                
                errorPointer?.pointee = error
                return nil
            }
            
            // Fetch game
            guard var game = try? freshSnapshot.data(as: Game.self) else {
                let error = GameServiceError.gameNotFound
                errorPointer?.pointee = error as NSError
                return nil
            }

            // Reject if player has already been in this game
            if game.players.contains(where: { $0.playerId == player.playerId }) {
                let error = GameServiceError.playerAlreadyInGame
                errorPointer?.pointee = error as NSError
                return nil
            }

            // Add new player
            game.players.append(player)
            game.playerIds.append(player.playerId)
            game.playerCount += 1
            game.activePlayerCount += 1
            game.totalPot += buyIn

            // Push data to firebase
            do {
                try transaction.setData(from: game, forDocument: gameRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
            
            
            return game
            } as! Game
        } catch let error as GameServiceError {
            throw error
        } catch {
            throw GameServiceError.networkError
        }
        
        return joinedGame
    }

    /// Sets a player's cash-out amount and marks them inactive via a Firestore transaction.
    /// Returns the player's total buy-in so the caller can compute profit for stats updates.
    func cashOut(gameId: String, userId: String, cashOut: Double) async throws -> Double {
        let gameRef = db.collection("games").document(gameId)

        let result = try await db.runTransaction { transaction, errorPointer in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(gameRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            // Fetch game
            guard var game = try? snapshot.data(as: Game.self) else {
                let error = GameServiceError.gameNotFound
                errorPointer?.pointee = error as NSError
                return nil
            }

            // Find player in game
            guard let playerIndex = game.players.firstIndex(where: { $0.playerId == userId }) else {
                let error = GameServiceError.playerNotInGame
                errorPointer?.pointee = error as NSError
                return nil
            }

            let playerBuyIn = game.players[playerIndex].buyIn

            // Validate cash-out doesn't exceed remaining pot
            if cashOut > game.totalPot {
                let error = GameServiceError.cashOutExceedsPot
                errorPointer?.pointee = error as NSError
                return nil
            }

            game.players[playerIndex].cashOut = cashOut
            game.players[playerIndex].isActive = false
            game.totalPot -= cashOut
            game.activePlayerCount -= 1

            // If no active players remain, deactivate the game
            var gameEnded = false
            if !game.players.contains(where: { $0.isActive }) {
                game.isActive = false
                game.endedAt = Date()
                gameEnded = true
                game.joinCodeEnabled = false
            }

            do {
                try transaction.setData(from: game, forDocument: gameRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            return [playerBuyIn, gameEnded ? 1.0 : 0.0] as NSArray
        }

        let resultArray = result as! NSArray
        let playerBuyIn = resultArray[0] as! Double

        return playerBuyIn
    }

    /// Adds a re-buy for the player, incrementing their buy-in and the game's total pot.
    func rebuy(gameId: String, userId: String, buyIn: Double) async throws {
        let gameRef = db.collection("games").document(gameId)

        try await db.runTransaction { transaction, errorPointer in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(gameRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            guard var game = try? snapshot.data(as: Game.self) else {
                let error = GameServiceError.gameNotFound
                errorPointer?.pointee = error as NSError
                return nil
            }

            guard game.isActive else {
                let error = GameServiceError.gameNotActive
                errorPointer?.pointee = error as NSError
                return nil
            }

            guard let playerIndex = game.players.firstIndex(where: { $0.playerId == userId }) else {
                let error = GameServiceError.playerNotInGame
                errorPointer?.pointee = error as NSError
                return nil
            }

            guard game.players[playerIndex].isActive else {
                let error = GameServiceError.playerNotActive
                errorPointer?.pointee = error as NSError
                return nil
            }

            game.players[playerIndex].buyIn += buyIn
            game.totalPot += buyIn

            do {
                try transaction.setData(from: game, forDocument: gameRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            return nil
        }
    }


    // MARK: - Past Games Pagination
    /// Resets state and fetches the first page of past games.
    func fetchPastGames(userId: String) async throws {
        pastGames = []
        lastPastGameDocument = nil
        hasMorePastGames = true
        try await fetchNextPastGamesPage(userId: userId)
    }

    /// Fetches the next page of ended games using cursor-based pagination.
    func fetchNextPastGamesPage(userId: String) async throws {
        guard !isLoadingPastGames, hasMorePastGames else { return }
        isLoadingPastGames = true
        defer { isLoadingPastGames = false }

        var query = db.collection("games")
            .whereField("playerIds", arrayContains: userId)
            .whereField("isActive", isEqualTo: false)
            .order(by: "startedAt", descending: true)
            .limit(to: pastGamesPageSize)

        if let lastDoc = lastPastGameDocument {
            query = query.start(afterDocument: lastDoc)
        }

        let snapshot = try await query.getDocuments()
        let newGames = snapshot.documents.compactMap { try? $0.data(as: Game.self) }

        pastGames.append(contentsOf: newGames)
        pastGames.sort { $0.startedAt > $1.startedAt }
        lastPastGameDocument = snapshot.documents.last
        if snapshot.documents.count < pastGamesPageSize {
            hasMorePastGames = false
        }
    }

    // MARK: - Private

    /// Generates a unique 6-character alphanumeric join code, retrying up to 10 times to avoid collisions.
    private func generateJoinCode() async throws -> String {
        for _ in 0..<10 {
            let code = String((0..<Self.joinCodeLength).map { _ in Self.joinCodeCharset.randomElement()! })

            let snapshot = try await db.collection("games")
                .whereField("joinCode", isEqualTo: code)
                .whereField("isActive", isEqualTo: true)
                .limit(to: 1)
                .getDocuments()

            if snapshot.documents.isEmpty {
                return code
            }
        }

        throw GameServiceError.joinCodeGenerationFailed
    }
}
