import SwiftUI

struct NameEditorSheet: View {
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                InputField(text: $viewModel.draftName, placeholder: "Display Name")
                    .font(.system(size: 20))
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .autocorrectionDisabled()

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showNameEditor = false }
                        .foregroundStyle(Theme.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await viewModel.saveName() }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.accent)
                    .disabled(viewModel.draftName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
