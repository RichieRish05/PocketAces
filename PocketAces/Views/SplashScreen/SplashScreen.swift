import SwiftUI

struct SplashScreen: View {

    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400)
        }
    }
}

#Preview {
    SplashScreen()
}
