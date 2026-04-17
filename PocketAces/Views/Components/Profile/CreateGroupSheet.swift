import SwiftUI

struct CreateGroupSheet: View {
    @Bindable var viewModel: GroupViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Give your group a name")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)

                InputField(text: $viewModel.newGroupName, placeholder: "Group Name")

                if let createError = viewModel.createErrorMessage {
                    Text(createError)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await viewModel.createGroup() }
                } label: {
                    Group {
                        if viewModel.isCreating {
                            ProgressView()
                                .tint(Color(red: 0.12, green: 0.10, blue: 0.06))
                        } else {
                            Text("Create Group")
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.newGroupName.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isCreating ? Theme.accent.opacity(0.4) : Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.newGroupName.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isCreating)
                .padding(.horizontal, 16)

                Spacer()
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showCreateSheet = false }
                        .foregroundStyle(Theme.dimAccent)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
