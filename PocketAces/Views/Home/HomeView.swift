import SwiftUI

struct HomeView: View {
    @Environment(UserStore.self) private var userStore

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to PocketAces " + (userStore.userData?.displayName ?? "!"))
                    .font(.title)
            }
            .navigationTitle("Home")
        }
    }
}
