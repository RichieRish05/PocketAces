import SwiftUI

struct AvatarSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Choose Your Avatar")
                .font(.largeTitle.bold())

            Text("Pick a custom look")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Avatar.all, id: \.self) { name in
                    avatarCell(name)
                }
            }
            .padding(.horizontal)

            Spacer()
            
            Button {
                viewModel.goToNameEntry()
            } label: {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canProceedToName)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }

    private func avatarCell(_ name: String) -> some View {
        let isSelected = viewModel.selectedAvatar == name

        return Image(name)
            .resizable()
            .frame(maxWidth: 125, maxHeight: 125)
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : .clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : .clear, lineWidth: 3)
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
            .onTapGesture {
                viewModel.selectedAvatar = name
            }
    }
}
