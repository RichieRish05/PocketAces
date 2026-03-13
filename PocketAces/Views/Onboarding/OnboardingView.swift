import SwiftUI

struct OnboardingView: View {
    @Environment(AuthService.self) private var authService
    @Environment(UserStore.self) private var userStore
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            AvatarSelectionView(viewModel: viewModel)
                .navigationDestination(isPresented: $viewModel.showNameEntry) {
                    NameEntryView(viewModel: viewModel)
                }
        }
        .onAppear {
            viewModel.authService = authService
            viewModel.userStore = userStore
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AuthService())
        .environment(UserStore())
}
