import Foundation
import SwiftUI

struct InputField: View {
    @Binding var text: String

    init(text: Binding<String>) {
        self._text = text
    }

    var body: some View {
        HStack {
            TextField("Display name", text: $text)
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

