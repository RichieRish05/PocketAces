import SwiftUI

struct GemBadge: View {
    @Environment(UserStore.self) private var userStore

    var body: some View {
        let gems = userStore.userData?.gems ?? 0
        HStack(spacing: 6) {
            Image("gem")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 22, height: 22)

            Text("\(gems)")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.accent)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
}
