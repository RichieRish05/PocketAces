import SwiftUI

struct NameEntryView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            if let avatar = viewModel.selectedAvatar {
                Image(avatar)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }

            Text("What should we call you?")
                .font(.largeTitle.bold())

            TextField("Display name", text: $viewModel.displayName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 32)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)

            Spacer()

            Button {
                Task {
                    await viewModel.finish()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Let's Go")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canFinish || viewModel.isLoading)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
