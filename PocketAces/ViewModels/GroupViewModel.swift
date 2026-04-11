import Foundation
import Observation

@Observable
final class GroupViewModel {
    // MARK: - Dependencies
    @ObservationIgnored private var groupService: PokerGroupService?
    @ObservationIgnored private var userStore: UserStore?

    // MARK: - Loading State
    var isLoading = false
    var isJoining = false
    var isCreating = false
    var isLeaving = false

    // MARK: - Error
    var errorMessage: String?
    var joinErrorMessage: String?
    var createErrorMessage: String?

    // MARK: - UI Input
    var joinCode = ""
    var newGroupName = ""
    var showJoinSheet = false
    var showCreateSheet = false

    // MARK: - Computed
    var groups: [PokerGroup] { groupService?.groups ?? [] }

    private var userId: String { userStore?.userData?.id ?? "" }
    private var displayName: String { userStore?.userData?.displayName ?? "Player" }
    private var avatarName: String { userStore?.userData?.avatarName ?? "avatar_01" }
    private var activeGroupCount: Int { userStore?.userData?.activeGroups.count ?? 0 }

    // MARK: - Setup

    func load(from userStore: UserStore, groupService: PokerGroupService) {
        self.userStore = userStore
        self.groupService = groupService
        Task { await fetchGroups() }
    }

    // MARK: - Fetch

    func fetchGroups() async {
        guard let userStore else { return }
        let ids = userStore.userData?.activeGroups ?? []
        isLoading = true
        defer { isLoading = false }
        do {
            try await groupService?.fetchGroups(ids: ids)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create

    func createGroup() async {
        let name = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            createErrorMessage = "Group name cannot be empty."
            return
        }

        isCreating = true
        createErrorMessage = nil
        defer { isCreating = false }
        do {
            let group = try await groupService?.createGroup(
                name: name,
                createdBy: userId,
                displayName: displayName,
                avatarName: avatarName,
                activeGroupCount: activeGroupCount
            )
            if let groupId = group?.id {
                addGroupLocally(groupId)
            }
            newGroupName = ""
            showCreateSheet = false
        } catch {
            createErrorMessage = error.localizedDescription
        }
    }

    // MARK: - Join

    func joinGroup() async {
        let code = joinCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else {
            joinErrorMessage = "Please enter a join code."
            return
        }

        isJoining = true
        joinErrorMessage = nil
        defer { isJoining = false }
        do {
            let group = try await groupService?.joinGroup(
                code: code,
                userId: userId,
                displayName: displayName,
                avatarName: avatarName,
                activeGroupCount: activeGroupCount
            )
            if let groupId = group?.id {
                addGroupLocally(groupId)
            }
            joinCode = ""
            showJoinSheet = false
        } catch {
            joinErrorMessage = error.localizedDescription
        }
    }

    // MARK: - Leave

    func leaveGroup(_ groupId: String) async {
        isLeaving = true
        defer { isLeaving = false }
        do {
            try await groupService?.leaveGroup(groupId: groupId, userId: userId)
            removeGroupLocally(groupId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private

    private func addGroupLocally(_ groupId: String) {
        guard var updated = userStore?.userData else { return }
        if !updated.activeGroups.contains(groupId) {
            updated.activeGroups.append(groupId)
            userStore?.save(updated)
        }
    }

    private func removeGroupLocally(_ groupId: String) {
        guard var updated = userStore?.userData else { return }
        updated.activeGroups.removeAll { $0 == groupId }
        userStore?.save(updated)
    }
}
