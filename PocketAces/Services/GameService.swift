import Foundation
import FirebaseFirestore

enum GameServiceError: LocalizedError {
    case gameNotFound
    case playerAlreadyInGame
    case playerNotInGame
    case joinCodeGenerationFailed

    var errorDescription: String? {
        switch self {
        case .gameNotFound: "Game not found."
        case .playerAlreadyInGame: "You're already in this game."
        case .playerNotInGame: "Player not found in this game."
        case .joinCodeGenerationFailed: "Failed to generate a unique join code. Please try again."
        }
    }
}

/// Stateless service that manages game CRUD operations against Firestore.
/// `activeGames` is updated optimistically by ViewModels on join/create/cash-out.
@Observable
final class GameService {
    private(set) var activeGames: [Game] = []
    private(set) var isLoadingGames = false

    private let db = Firestore.firestore()

    private static let joinCodeCharset = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
    private static let joinCodeLength = 6

    // MARK: - Public

    /// Fetches all active games the user is part of and replaces `activeGames`.
    func fetchGames(userId: String) async throws {
        isLoadingGames = true
        defer { isLoadingGames = false }

        async let activeQuery = db.collection("games")
            .whereField("playerIds", arrayContains: userId)
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
    
        let activeSnapshot = try await activeQuery
        activeGames = activeSnapshot.documents.compactMap { try? $0.data(as: Game.self) }
        
    }

    /// Creates a new game document in Firestore with the host as the first player.
    /// Returns the created `Game` with its Firestore document ID set.
    func createGame(name: String, hostId: String, hostDisplayName: String, buyIn: Double, chipDenominations: [ChipDenomination]) async throws -> Game {
        let joinCode = try await generateJoinCode()

        let host = Player(
            playerId: hostId,
            buyIn: buyIn,
            cashOut: 0,
            isActive: true
        )

        let game = Game(
            name: name,
            chipDenominations: chipDenominations,
            hostDisplayName: hostDisplayName,
            hostId: hostId,
            joinCode: joinCode,
            joinCodeEnabled: true,
            playerCount: 1,
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
        let snapshot = try await db.collection("games")
            .whereField("joinCode", isEqualTo: joinCode.uppercased())
            .whereField("isActive", isEqualTo: true)
            .getDocuments()

        guard let document = snapshot.documents.first else {
            throw GameServiceError.gameNotFound
        }

        let gameRef = document.reference

        return try await db.runTransaction { transaction, errorPointer in
            let freshSnapshot: DocumentSnapshot
            do {
                freshSnapshot = try transaction.getDocument(gameRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            guard var game = try? freshSnapshot.data(as: Game.self) else {
                let error = GameServiceError.gameNotFound
                errorPointer?.pointee = error as NSError
                return nil
            }

            if game.playerIds.contains(player.playerId) {
                let error = GameServiceError.playerAlreadyInGame
                errorPointer?.pointee = error as NSError
                return nil
            }

            game.players.append(player)
            game.playerIds.append(player.playerId)
            game.playerCount += 1
            game.totalPot += buyIn

            do {
                try transaction.setData(from: game, forDocument: gameRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            return game
        } as! Game
    }

    /// Sets a player's cash-out amount and marks them inactive via a Firestore transaction.
    /// Returns the player's total buy-in so the caller can compute profit for stats updates.
    func cashOut(gameId: String, userId: String, cashOut: Double) async throws -> Double {
        let gameRef = db.collection("games").document(gameId)

        return try await db.runTransaction { transaction, errorPointer in
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

            guard let playerIndex = game.players.firstIndex(where: { $0.playerId == userId }) else {
                let error = GameServiceError.playerNotInGame
                errorPointer?.pointee = error as NSError
                return nil
            }

            let playerBuyIn = game.players[playerIndex].buyIn

            game.players[playerIndex].cashOut = cashOut
            game.players[playerIndex].isActive = false

            // If no active players remain, deactivate the game
            if !game.players.contains(where: { $0.isActive }) {
                game.isActive = false
            }

            do {
                try transaction.setData(from: game, forDocument: gameRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            return playerBuyIn as NSNumber
        } as! Double
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

            guard let playerIndex = game.players.firstIndex(where: { $0.playerId == userId }) else {
                let error = GameServiceError.playerNotInGame
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
