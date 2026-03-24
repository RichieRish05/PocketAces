import SwiftUI

struct SkeletonGameCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 140, height: 14)
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 100, height: 10)
                }

                Spacer()
            }

            Divider()

            ForEach(0..<3, id: \.self) { _ in
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 80, height: 12)
                    Spacer()
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 50, height: 12)
                }
            }
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .redacted(reason: .placeholder)
    }
}
