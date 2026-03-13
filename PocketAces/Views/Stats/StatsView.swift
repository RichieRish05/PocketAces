import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No Stats Yet",
                systemImage: "chart.bar.fill",
                description: Text("Play some games to see your stats here.")
            )
            .navigationTitle("Stats")
        }
    }
}
