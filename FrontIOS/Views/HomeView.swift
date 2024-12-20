import SwiftUI

struct HomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel: HomeViewModel
    
    init(authService: NetworkService = NetworkService(),
         eventService: EventService = EventService.shared,
         studyPlanService: StudyPlanService = StudyPlanService.shared) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(
            authService: authService,
            eventService: eventService,
            studyPlanService: studyPlanService
        ))
    }
    
    var body: some View {
        
        ScrollView {
            VStack {
                WelcomeBannerView(userName: viewModel.userName)
                
                MoodAnalyticsView(viewModel: viewModel)
                    .background(Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#fdfee4"))
                
                if let studyPlan = viewModel.currentStudyPlan {
                    StudyProgressView(studyPlan: studyPlan)
                }
                
                RecommendedEventsView(
                    events: viewModel.recommendedEvents,
                    mood: viewModel.currentMood
                )
                
                DailyMotivationView(
                    quote: viewModel.dailyQuote,
                    mood: viewModel.currentMood
                )
            }
            .padding()
            
        }
        .background(Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#fef2e4").edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.loadHomeData()
        }
    }
}

#Preview {
    HomeView()
}
