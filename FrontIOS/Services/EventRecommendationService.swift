import Foundation

class EventRecommendationService {
    static let shared = EventRecommendationService()
    private let baseURL = "http://172.18.25.95:3000"
    
    func fetchRecommendedEvents() async throws -> EventRecommendationResponse {
        guard let url = URL(string: "\(baseURL)/events/recommendations/daily") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // For debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Received JSON:", jsonString)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(EventRecommendationResponse.self, from: data)
    }
    
    func fetchEventDetails(_ eventId: String) async throws -> Event {
        guard let url = URL(string: "\(baseURL)/events/\(eventId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode(Event.self, from: data)
    }
}
