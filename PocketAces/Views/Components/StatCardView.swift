import SwiftUI

enum StatFormat {
    case percentage
    case currency
    case integer
}

private func formattedString(_ value: Double, format: StatFormat) -> String {
    switch format {
    case .percentage:
        "\(Int(value))%"
    case .currency:
        value.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    case .integer:
        "\(Int(value))"
    }
}

private struct CountUpModifier: ViewModifier, Animatable {
    var value: Double
    let format: StatFormat
    let color: Color

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    func body(content: Content) -> some View {
        content.overlay(alignment: .leading) {
            Text(formattedString(value, format: format))
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
    }
}

struct StatCardView: View {
    let icon: String
    let label: String
    let numericValue: Double
    let format: StatFormat
    let valueColor: Color

    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(label)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            ZStack(alignment: .leading) {
                // Hidden text reserves space for the final value
                Text(formattedString(numericValue, format: format))
                    .font(.title)
                    .fontWeight(.bold)
                    .hidden()

                // Invisible content for the modifier to overlay
                Color.clear
                    .frame(height: 0)
                    .modifier(CountUpModifier(
                        value: isAnimating ? numericValue : 0,
                        format: format,
                        color: valueColor
                    ))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    .ultraThinMaterial,
                    lineWidth: 2
                )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1)) {
                isAnimating = true
            }
        }
    }
}
