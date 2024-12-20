import SwiftUI

// MARK: - Mood
enum Mood: String, CaseIterable {
    case happy = "Happy"
    case sad = "Sad"
    case neutral = "Neutral"
    case angry = "Angry"
    case excited = "Excited"
    
    var color: Color {
        switch self {
        case .happy: return .green
        case .sad: return .blue
        case .neutral: return .gray
        case .angry: return .red
        case .excited: return .orange
        }
    }
}

// MARK: - EmotionStats
struct EmotionStats: Codable {
    let emotionsByDate: [String: [String: Int]]
    let totalEmotions: Int
    let dateRange: DateRange
    
    struct DateRange: Codable {
        let start: String
        let end: String
    }
}

// MARK: - MoodEntry
struct MoodEntry: Identifiable {
    let id = UUID()
    let date: Date
    let emotion: String
    let count: Int
}

// MARK: - TimeRange
enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    
    var id: String { self.rawValue }
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        }
    }
}
// MARK: - Notification
struct Notification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: NotificationType
    let date: Date
}

// MARK: - NotificationType
enum NotificationType {
    case exam
    case event
    case mood
    case general
}
struct QuoteResponse: Codable {
    let quote: String
    let mood: String
    let createdAt: String
}

struct DailyQuote: Identifiable {
    let id = UUID()
    let quote: String
    let mood: String
    let createdAt: Date
}
