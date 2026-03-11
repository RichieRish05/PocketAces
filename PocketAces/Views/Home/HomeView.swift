import SwiftUI

struct HomeView: View {
    @Environment(UserProfileStore.self) private var profileStore

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to PocketAces " + (profileStore.profile?.displayName ?? "!"))
                    .font(.title)
            }
            .navigationTitle("Home")
        }
    }
}
