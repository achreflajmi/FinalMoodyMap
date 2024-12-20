import SwiftUI

struct BottomNavBarView: View {
    @State private var selectedTab: Tab = .home
    @ObservedObject var authManager: AuthenticationManager
    @Environment(\.colorScheme) var colorScheme // To detect dark/light mode

    var body: some View {
        VStack(spacing: 0) {
            // Display the content for the selected tab
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .moodTracking:
                    MoodTrackingView()
                case .academicPlanner:
                    AcademicPlannerView()
                case .events:
                    EventsView()
                case .profile:
                    ProfileView(authManager: authManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom navigation bar
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 24))
                                .foregroundColor(
                                    selectedTab == tab
                                        ? (colorScheme == .dark
                                            ? Color(hex: "#ffdb3a")
                                            : Color.secondary) // Normal color for light mode
                                        : Color.secondary
                                )
                            Text(tab.title)
                                .font(.footnote)
                                .foregroundColor(
                                    selectedTab == tab
                                        ? (colorScheme == .dark
                                            ? Color(hex: "#ffdb3a")
                                            : Color.secondary) // Normal color for light mode
                                        : Color.secondary
                                )
                        }
                    }
                    .frame(maxWidth: .infinity) // Ensures buttons are evenly spaced
                }
            }
            .padding()
            .background(
                colorScheme == .dark
                    ? Color(hex: "#1c1c1e") // Dark background for dark mode
                    : Color(hex: "#fef2e4") // Light background for light mode
            )
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

enum Tab: String, CaseIterable {
    case home = "Home"
    case moodTracking = "Mood Tracking"
    case academicPlanner = "Academic Planner"
    case events = "Events"
    case profile = "Profile"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .moodTracking: return "Mood"
        case .academicPlanner: return "Planner"
        case .events: return "Events"
        case .profile: return "Profile"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "house"
        case .moodTracking: return "face.smiling"
        case .academicPlanner: return "calendar"
        case .events: return "bell"
        case .profile: return "person.crop.circle"
        }
    }
}

// Preview
#Preview {
    BottomNavBarView(authManager: AuthenticationManager())
}
