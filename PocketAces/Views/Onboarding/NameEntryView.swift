import SwiftUI

struct NameEntryView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 32) {
            
            VStack(alignment: .leading) {
                Text("What should we call you?")
                    .font(.title)
                Text("You can change this in your settings later on.")
                    .foregroundStyle(.secondary)
            }
            .padding(.trailing, 5)
            .padding(.top, 75)
            
            InputField(text: $viewModel.displayName)

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


#Preview {
    NameEntryView(viewModel: OnboardingViewModel())

}
