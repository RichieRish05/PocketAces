import Foundation
import FirebaseFirestore
import Observation

enum PokerGroupServiceError: LocalizedError {
    case groupNotFound
    case alreadyMember
    case joinCodeNotFound
    case joinCodeCollision
    case groupFull
    case tooManyActiveGroups

    var errorDescription: String? {
        switch self {
        case .groupNotFound: "Group not found."
        case .alreadyMember: "You're already a member of this group."
        case .joinCodeNotFound: "No active group found with that join code."
        case .joinCodeCollision: "Failed to generate a unique join code. Please try again."
        case .groupFull: "The group you're trying to join is already full."
        case .tooManyActiveGroups: "You are in too many active groups"
        }
    }
}

@Observable
final class PokerGroupService {
    var groups: [PokerGroup] = []

    private let db = Firestore.firestore()

    // MARK: - Create

    func createGroup(name: String, createdBy userId: String, displayName: String, avatarName: String, activeGroupCount: Int) async throws -> PokerGroup {
        guard activeGroupCount < 3 else {
            throw PokerGroupServiceError.tooManyActiveGroups
        }

        let joinCode = try await generateJoinCode()

        let creator = PokerGroupMember(
            userId: userId,
            displayName: displayName,
            avatarName: avatarName,
            joinedAt: Date(),
            totalBuyIn: 0,
            totalCashOut: 0,
            gamesPlayed: 0,
            wins: 0
        )

        let group = PokerGroup(
            name: name,
            createdBy: userId,
            members: [creator],
            memberIds: [userId],
            gameIds: [],
            createdAt: Date(),
            isActive: true,
            joinCode: joinCode
        )

        let groupRef = db.collection("groups").document()
        let userRef = db.collection("users").document(userId)

        let batch = db.batch()
        try batch.setData(from: group, forDocument: groupRef)
        batch.updateData(["activeGroups": FieldValue.arrayUnion([groupRef.documentID])], forDocument: userRef)
        try await batch.commit()

        var createdGroup = group
        createdGroup.id = groupRef.documentID
        groups.append(createdGroup)
        return createdGroup
    }

    // MARK: - Join

    func joinGroup(code: String, userId: String, displayName: String, avatarName: String, activeGroupCount: Int) async throws -> PokerGroup {
        guard activeGroupCount < 3 else {
            throw PokerGroupServiceError.tooManyActiveGroups
        }

        let snapshot = try await db.collection("groups")
            .whereField("joinCode", isEqualTo: code.uppercased())
            .whereField("isActive", isEqualTo: true)
            .getDocuments()

        guard let document = snapshot.documents.first else {
            throw PokerGroupServiceError.joinCodeNotFound
        }

        guard var group = try? document.data(as: PokerGroup.self), group.isActive else {
            throw PokerGroupServiceError.groupNotFound
        }

        if group.memberIds.contains(userId) {
            throw PokerGroupServiceError.alreadyMember
        }

        guard group.members.count < 25 else {
            throw PokerGroupServiceError.groupFull
        }

        let groupRef = document.reference
        let userRef = db.collection("users").document(userId)
        let groupId = document.documentID

        let updatedGroup = try await db.runTransaction { transaction, errorPointer in
            let freshSnapshot: DocumentSnapshot
            do { freshSnapshot = try transaction.getDocument(groupRef) }
            catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard var freshGroup = try? freshSnapshot.data(as: PokerGroup.self), freshGroup.isActive else {
                errorPointer?.pointee = NSError(domain: "PokerGroupService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Group not found."])
                return nil
            }

            if freshGroup.memberIds.contains(userId) {
                errorPointer?.pointee = NSError(domain: "PokerGroupService", code: 2, userInfo: [NSLocalizedDescriptionKey: "You're already a member of this group."])
                return nil
            }

            guard freshGroup.members.count < 25 else {
                errorPointer?.pointee = NSError(domain: "PokerGroupService", code: 3, userInfo: [NSLocalizedDescriptionKey: "The group you're trying to join is already full."])
                return nil
            }

            let newMember = PokerGroupMember(
                userId: userId,
                displayName: displayName,
                avatarName: avatarName,
                joinedAt: Date(),
                totalBuyIn: 0,
                totalCashOut: 0,
                gamesPlayed: 0,
                wins: 0
            )

            freshGroup.members.append(newMember)
            freshGroup.memberIds.append(userId)

            do { try transaction.setData(from: freshGroup, forDocument: groupRef) }
            catch let encodeError as NSError {
                errorPointer?.pointee = encodeError
                return nil
            }

            transaction.updateData(["activeGroups": FieldValue.arrayUnion([groupId])], forDocument: userRef)

            return freshGroup
        }

        guard let updatedGroup = updatedGroup as? PokerGroup else {
            throw PokerGroupServiceError.groupNotFound
        }

        groups.append(updatedGroup)
        return updatedGroup
    }

    // MARK: - Leave

    func leaveGroup(groupId: String, userId: String) async throws {
        let groupRef = db.collection("groups").document(groupId)
        let userRef = db.collection("users").document(userId)

        try await db.runTransaction { transaction, errorPointer in
            let freshSnapshot: DocumentSnapshot
            do { freshSnapshot = try transaction.getDocument(groupRef) }
            catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard var group = try? freshSnapshot.data(as: PokerGroup.self), group.isActive else {
                errorPointer?.pointee = NSError(domain: "PokerGroupService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Group not found."])
                return nil
            }

            group.memberIds.removeAll { $0 == userId }
            group.members.removeAll { $0.userId == userId }

            if group.memberIds.isEmpty {
                group.isActive = false
            }

            do { try transaction.setData(from: group, forDocument: groupRef) }
            catch let encodeError as NSError {
                errorPointer?.pointee = encodeError
                return nil
            }

            transaction.updateData(["activeGroups": FieldValue.arrayRemove([groupId])], forDocument: userRef)

            return nil
        }

        groups.removeAll { $0.id == groupId }
    }

    // MARK: - Fetch

    func fetchGroups(ids: [String]) async throws {
        guard !ids.isEmpty else {
            groups = []
            return
        }

        let snapshot = try await db.collection("groups")
            .whereField(FieldPath.documentID(), in: ids)
            .whereField("isActive", isEqualTo: true)
            .getDocuments()

        groups = snapshot.documents.compactMap { try? $0.data(as: PokerGroup.self) }
            .map { group in
                var g = group
                g.members.sort { $0.totalProfit > $1.totalProfit }
                return g
            }
    }

    // MARK: - Private

    private func generateJoinCode() async throws -> String {
        for _ in 0..<10 {
            let code = JoinCode.generate()

            let snapshot = try await db.collection("groups")
                .whereField("joinCode", isEqualTo: code)
                .whereField("isActive", isEqualTo: true)
                .limit(to: 1)
                .getDocuments()

            if snapshot.documents.isEmpty {
                return code
            }
        }

        throw PokerGroupServiceError.joinCodeCollision
    }
}
