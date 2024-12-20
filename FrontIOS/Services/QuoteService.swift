import Foundation

class QuoteService {
    static let shared = QuoteService()
    private let baseURL = "http://172.18.25.95:3000"
    
    func fetchDailyQuote() async throws -> QuoteResponse {
        guard let url = URL(string: "\(baseURL)/quotes/daily") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode(QuoteResponse.self, from: data)
    }
}
