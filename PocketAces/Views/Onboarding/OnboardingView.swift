import SwiftUI

struct OnboardingView: View {
    @Environment(UserProfileStore.self) private var profileStore
    @State private var viewModel: OnboardingViewModel

    init(authService: AuthService) {
        _viewModel = State(initialValue: OnboardingViewModel(authService: authService))
    }

    var body: some View {
        NavigationStack {
            AvatarSelectionView(viewModel: viewModel)
                .navigationDestination(isPresented: $viewModel.showNameEntry) {
                    NameEntryView(viewModel: viewModel)
                }
        }
        .onAppear {
            viewModel.profileStore = profileStore
        }
    }
}

#Preview {
    OnboardingView(authService: AuthService())
        .environment(UserProfileStore())
}
