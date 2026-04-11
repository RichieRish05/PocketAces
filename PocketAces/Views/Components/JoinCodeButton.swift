import SwiftUI
import UIKit

struct JoinCodeButton: View {
    let joinCode: String

    var body: some View {
        Button {
            UIPasteboard.general.string = joinCode
        } label: {
            HStack(spacing: 5) {
                Text(joinCode)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.dimAccent)
                    .tracking(1)

                Image(systemName: "doc.on.doc")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.dimAccent)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
        }
        .buttonStyle(.plain)
    }
}
