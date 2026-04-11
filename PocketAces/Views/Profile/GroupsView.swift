import SwiftUI

struct GroupsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "person.3")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(Color(white: 0.35))
            Text("Groups coming soon")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color(white: 0.4))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationTitle("Groups")
        .navigationBarTitleDisplayMode(.inline)
    }
}
