import SwiftUI

struct JoinGroupSheet: View {
    @Bindable var viewModel: GroupViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter the group's join code")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)

                TextField("Join Code", text: $viewModel.joinCode)
                    .textFieldStyle(.plain)
                    .font(.title2)
                    .monospaced()
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Theme.accent.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .onChange(of: viewModel.joinCode) { _, newValue in
                        viewModel.joinCode = String(newValue.prefix(6)).uppercased()
                    }

                if let joinError = viewModel.joinErrorMessage {
                    Text(joinError)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await viewModel.joinGroup() }
                } label: {
                    Group {
                        if viewModel.isJoining {
                            ProgressView()
                                .tint(Color(red: 0.12, green: 0.10, blue: 0.06))
                        } else {
                            Text("Join Group")
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.joinCode.count < 6 || viewModel.isJoining ? Theme.accent.opacity(0.4) : Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.joinCode.count < 6 || viewModel.isJoining)
                .padding(.horizontal, 16)

                Spacer()
            }
            .navigationTitle("Join Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showJoinSheet = false }
                        .foregroundStyle(Theme.dimAccent)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
