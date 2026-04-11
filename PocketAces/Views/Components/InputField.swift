import Foundation
import SwiftUI

struct InputField: View {
    @Binding var text: String
    var placeholder: String

    init(text: Binding<String>, placeholder: String = "Display name") {
        self._text = text
        self.placeholder = placeholder
    }

    var body: some View {
        VStack (alignment: .leading){
            TextField(placeholder, text: $text)
                .font(.system(size: 22))
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Theme.accent.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
    
}


struct CurrencyInputField: View {
    @Binding var value: Double

    @State private var centString: String = ""
    @FocusState private var isFocused: Bool
    private let maxDigits = 7

    /// Formats cents integer into display parts: (dollars, cents)
    /// e.g. centString "12345" → ("123", "45") → "$123.45"
    private var formattedParts: (dollar: String, cents: String) {
        if centString.isEmpty {
            return ("0", "00")
        }
        let padded = centString.count < 3
            ? String(repeating: "0", count: 3 - centString.count) + centString
            : centString
        let decimalIndex = padded.index(padded.endIndex, offsetBy: -2)
        let dollarRaw = String(padded[padded.startIndex..<decimalIndex])
        let cents = String(padded[decimalIndex...])

        // Add comma grouping to dollar portion
        if let dollarInt = Int(dollarRaw) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            let dollarFormatted = formatter.string(from: NSNumber(value: dollarInt)) ?? dollarRaw
            return (dollarFormatted, cents)
        }
        return (dollarRaw, cents)
    }

    var body: some View {
        ZStack {
            // Hidden text field that captures keyboard input
            TextField("", text: $centString)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .opacity(0)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
                .onChange(of: centString) { _, newValue in
                    var filtered = String(newValue.filter { $0.isWholeNumber }.prefix(maxDigits))
            
                    // Strip leading zeros (keep at least one "0" if all zeros)
                    while filtered.count > 1 && filtered.first == "0" {
                        filtered.removeFirst()
                    }
                    
                    if filtered != newValue {
                        centString = filtered
                        return
                    }
                    
                    
                    value = Double(filtered).map { $0 / 100.0 } ?? 0
                }

            // Visible currency display
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                let parts = formattedParts
                Text("$\(parts.dollar).\(parts.cents)")
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .foregroundStyle(centString.isEmpty ? .secondary : .primary)

                if isFocused {
                    CursorView()
                        .padding(.leading, 1)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Theme.accent.opacity(0.3), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .onAppear {
            if value > 0 {
                centString = String(Int(round(value * 100)))
            }
        }
    }

}

private struct CursorView: View {
    @State private var visible = true

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(.tint)
            .frame(width: 2, height: 22)
            .opacity(visible ? 1 : 0)
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(530))
                    visible.toggle()
                }
            }
    }
}
