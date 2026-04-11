import SwiftUI

struct NameEntryView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What should we call you?")
                    .font(.system(size: 28, weight: .bold))
                Text("You can change this later in your profile.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 32)

            InputField(text: $viewModel.displayName)
                .padding(.top, 24)

            Spacer()

            Button {
                Task { await viewModel.finish() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    Text("Let's Go")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(viewModel.canFinish && !viewModel.isLoading ? Theme.accent : Theme.dimAccent.opacity(0.4))
            )
            .disabled(!viewModel.canFinish || viewModel.isLoading)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationTitle("Name")
        .navigationBarTitleDisplayMode(.inline)
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
