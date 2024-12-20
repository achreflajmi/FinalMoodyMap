import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var userName: String = ""
    @Published var moodData: [MoodEntry] = []
    @Published var currentStudyPlan: StudyPlan?
    @Published var recommendedEvents: [Event] = []
    @Published var recentNotifications: [Notification] = []
    @Published var emotionStats: EmotionStats?
    @Published var moodEntries: [MoodEntry] = []
    @Published var selectedTimeRange: TimeRange = .week
    @Published var dailyQuote: String = ""
    @Published var currentMood: String?
    @Published var isLoading = false
      @Published var error: String?
    private let quoteService = QuoteService.shared
    private var cancellables = Set<AnyCancellable>()
    private let authService: NetworkService
    private let eventService: EventService
    private let studyPlanService: StudyPlanService
    private let eventRService = EventRecommendationService.shared

    // Remove the EmotionService property since we now use the shared static instance
    // private let EmotionService: MoodTrackingViewModel

    init(authService: NetworkService,
         eventService: EventService,
         studyPlanService: StudyPlanService) {
        self.authService = authService
        self.eventService = eventService
        self.studyPlanService = studyPlanService
    }
    
    func loadHomeData() {
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.loadUserProfile() }
                group.addTask { await self.loadMoodData() }
                group.addTask { await self.loadRecommendedEvents() }
                group.addTask { await self.loadNotifications() }
                group.addTask { await self.generateDailyQuote() }
            }
        }
    }
    
    private func loadUserProfile() async {
        do {
            let userDetails = try await authService.getUserDetails()
            userName = userDetails.name
        } catch {
            print("Error loading user profile: \(error)")
        }
    }
    
    func loadMoodData() async {
        do {
            let stats = try await MoodTrackingViewModel.shared.fetchEmotionStats(days: selectedTimeRange.days)
            self.emotionStats = stats
            self.moodEntries = processEmotionStats(stats)
        } catch {
            print("Error loading mood data: \(error)")
        }
    }
    
    private func processEmotionStats(_ stats: EmotionStats) -> [MoodEntry] {
         var entries: [MoodEntry] = []
         var totalsByEmotion: [String: Int] = [:]
         
         // Aggregate emotions across all dates
         for (_, emotions) in stats.emotionsByDate {
             for (emotion, count) in emotions {
                 totalsByEmotion[emotion] = (totalsByEmotion[emotion] ?? 0) + count
             }
         }
         
         // Create entries for each emotion
         for (emotion, count) in totalsByEmotion {
             entries.append(MoodEntry(
                 date: Date(), // Date is no longer relevant for this visualization
                 emotion: emotion,
                 count: count
             ))
         }
         
         return entries.sorted { $0.count > $1.count }
     }
     
     func updateTimeRange(_ range: TimeRange) {
         selectedTimeRange = range
         Task {
             await loadMoodData()
         }
     }

    func loadRecommendedEvents() async {
        isLoading = true
        error = nil
        
        do {
            let recommendations = try await eventRService.fetchRecommendedEvents()
            currentMood = recommendations.mood
            
            // Events are now directly in the response
            self.recommendedEvents = recommendations.recommendations
            
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            print("Error loading recommended events: \(error)")
        }
    }


    
    private func generateDailyQuote() async {
        do {
            let quoteResponse = try await quoteService.fetchDailyQuote()
            await MainActor.run {
                self.dailyQuote = quoteResponse.quote
                self.currentMood = quoteResponse.mood
            }
        } catch {
            print("Error loading daily quote: \(error)")
            await MainActor.run {
                self.dailyQuote = "Every challenge is an opportunity for growth."
            }
        }
    }
    
    private func loadNotifications() async {
        // Implement notifications loading logic
    }
}
