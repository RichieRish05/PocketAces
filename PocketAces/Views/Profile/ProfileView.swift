import SwiftUI

struct ProfileView: View {
    @Environment(UserStore.self) private var userStore

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text(userStore.userData?.displayName ?? "Player")
                                .font(.title2.bold())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Profile")
        }
    }
}
