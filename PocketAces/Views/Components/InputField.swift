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
        HStack {
            TextField(placeholder, text: $text)
                .font(.title2)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)

            Spacer()

            Button {
                // help action
            } label: {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.secondary, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
    
}


struct CurrencyInputField: View {
    @Binding var value: Double

    @State private var centString: String = ""
    @FocusState private var isFocused: Bool

    private let maxDigits = 7

    private var displayString: String {
        if centString.isEmpty {
            return "$-.--"
        }
        let padded = centString.count < 3
            ? String(repeating: "0", count: 3 - centString.count) + centString
            : centString
        let decimalIndex = padded.index(padded.endIndex, offsetBy: -2)
        let dollars = String(padded[padded.startIndex..<decimalIndex])
        let cents = String(padded[decimalIndex...])
        let dollarsDisplay = dollars.allSatisfy({ $0 == "0" }) ? "-" : dollars
        return "$\(dollarsDisplay).\(cents)"
    }

    var body: some View {
        ZStack {
            TextField("", text: $centString)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .opacity(0)
                .allowsHitTesting(false)
                .onChange(of: centString) { _, newValue in
                    let filtered = String(newValue.filter { $0.isWholeNumber }.prefix(maxDigits))
                    if filtered != newValue {
                        centString = filtered
                        return
                    }
                    value = Double(filtered).map { $0 / 100.0 } ?? 0
                }

            Text(displayString)
                .font(.title2)
                .monospaced()
                .contentTransition(.numericText())
                .onTapGesture {
                    isFocused = true
                }
        }
        .onAppear {
            if value > 0 {
                centString = String(Int(round(value * 100)))
            }
        }
    }
}
