import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        VStack(spacing: 0) {
            // Content area
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .stats:
                    StatsView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            customTabBar
        }
    }

    private var customTabBar: some View {
        VStack(spacing: 0) {
            // Gold hairline separator
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.gold.opacity(0.0),
                            Theme.gold.opacity(0.25),
                            Theme.gold.opacity(0.25),
                            Theme.gold.opacity(0.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)

            // Tab items
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    tabItem(tab)
                }
            }
            .padding(.top, 12)
        }
        .background(Color(red: 0.06, green: 0.06, blue: 0.08))
        .safeAreaPadding(.bottom)
    }

    private func tabItem(_ tab: AppTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.snappy(duration: 0.25)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Theme.gold : Color.white.opacity(0.3))
                }
                .frame(height: 24)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Theme.gold : Color.white.opacity(0.3))
                    .tracking(isSelected ? 0.4 : 0)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tab Definition

enum AppTab: String, CaseIterable {
    case home
    case stats
    case profile

    var title: String {
        switch self {
        case .home: "Home"
        case .stats: "Stats"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .stats: "chart.bar"
        case .profile: "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: "house.fill"
        case .stats: "chart.bar.fill"
        case .profile: "person.fill"
        }
    }
}

#Preview {
    MainTabView()
        .environment(AuthService())
        .environment(UserStore())
}
