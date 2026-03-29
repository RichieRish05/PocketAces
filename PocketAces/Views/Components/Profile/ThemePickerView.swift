import SwiftUI

struct ThemePickerView: View {
    @Environment(Theme.self) private var theme
    @Bindable var viewModel: ProfileViewModel

    @State private var selected: ThemePackage = Theme.shared.currentPackage

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(ThemePackage.allCases) { package in
                    let isSelected = selected == package
                    Button {
                        selected = package
                    } label: {
                        themeCard(package: package, isSelected: isSelected)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .navigationTitle("Choose Theme")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.saveTheme(selected) }
                }
                .fontWeight(.semibold)
                .foregroundStyle(theme.accent)
            }
        }
    }

    private func themeCard(package: ThemePackage, isSelected: Bool) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                colorSwatch(package.accent)
                colorSwatch(package.dimAccent)
                colorSwatch(package.primary)
                colorSwatch(package.primaryDark)
            }

            Text(package.displayName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(white: 0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isSelected ? package.accent : package.dimAccent.opacity(0.3),
                    lineWidth: isSelected ? 3 : 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private func colorSwatch(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 28, height: 28)
    }
}
