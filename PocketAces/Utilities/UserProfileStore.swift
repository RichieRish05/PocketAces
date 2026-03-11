import Foundation

@Observable
final class UserProfileStore {
    private(set) var profile: UserProfile?

    private let key = "userProfile"

    init() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        profile = try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    func save(_ profile: UserProfile) {
        let data = try? JSONEncoder().encode(profile)
        UserDefaults.standard.set(data, forKey: key)
        self.profile = profile
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
        profile = nil
    }
}
