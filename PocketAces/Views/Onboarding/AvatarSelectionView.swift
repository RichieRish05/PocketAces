import SwiftUI

struct AvatarSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Choose Your Avatar")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top, 8)

                    Text("Pick a custom look")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Avatar.all, id: \.self) { name in
                            avatarCell(name)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
            }

            Button {
                viewModel.goToNameEntry()
            } label: {
                Text("Next")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(viewModel.canProceedToName ? Theme.gold : Theme.dimGold.opacity(0.4))
                    )
            }
            .disabled(!viewModel.canProceedToName)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationTitle("Avatar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func avatarCell(_ name: String) -> some View {
        let isSelected = viewModel.selectedAvatar == name

        return Button {
            viewModel.selectedAvatar = name
        } label: {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Theme.gold : Theme.dimGold.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}
