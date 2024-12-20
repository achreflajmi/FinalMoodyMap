import Foundation

class EventService {
    static let shared = EventService()
    private let baseURL = "http://172.18.25.95:3000/events"
    
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    func fetchEvents() async throws -> [Event] {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Print response and data for debugging
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Received JSON: \(jsonString)")
        }
        
        return try jsonDecoder.decode([Event].self, from: data)
    }
    
    func participateInEvent(eventId: String) async throws -> Event {
        guard let url = URL(string: "\(baseURL)/\(eventId)/participate") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "authToken") ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try jsonDecoder.decode(Event.self, from: data)
    }
    
    func downloadVoucher(eventId: String) async throws -> URL {
        guard let url = URL(string: "\(baseURL)/\(eventId)/voucher") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "authToken") ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Save PDF to temporary directory
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(eventId)-voucher.pdf")
        try data.write(to: tempURL)
        return tempURL
    }
}
