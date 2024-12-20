import Foundation

struct Event: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let date: String // Changed to String to avoid date parsing issues
    let location: String
    let capacity: Int
    let participants: [String]
    let imageUrl: String
    var updatedAt: String? // Changed to String
    var createdAt: String? // Changed to String
    var __v: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case date
        case location
        case capacity
        case participants
        case imageUrl
        case updatedAt
        case createdAt
        case __v
    }
    
    // Helper method to format date for display
    func formattedDate() -> String {
        guard let isoDate = ISO8601DateFormatter().date(from: date) else {
            return date // Return original string if parsing fails
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: isoDate)
    }
}

struct EventRecommendationResponse: Codable {
    let recommendations: [Event]
    let mood: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case recommendations
        case mood
        case createdAt
    }
}
