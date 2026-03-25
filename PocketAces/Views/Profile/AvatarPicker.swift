import SwiftUI

struct AvatarPickerView: View {
    @Bindable var viewModel: ProfileViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Avatar.all, id: \.self) { name in
                    let isSelected = viewModel.selectedAvatar == name
                    Button {
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
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .navigationTitle("Choose Avatar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.saveAvatar() }
                }
                .fontWeight(.semibold)
                .foregroundStyle(Theme.gold)
            }
        }
    }
}

