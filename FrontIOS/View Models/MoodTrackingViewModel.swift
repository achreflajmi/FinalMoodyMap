import Foundation
import SwiftUI
import UIKit

class MoodTrackingViewModel: ObservableObject {
    @Published var detectedEmotion: String = ""
    @Published var detectedUserId: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    private let baseURL = "http://172.18.25.95:3000"
    private let tokenKey = "authToken" // Key to store the token
    static let shared = MoodTrackingViewModel()

    func detectEmotion(from image: UIImage) {
        isLoading = true
        errorMessage = ""

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            errorMessage = "Failed to process image"
            isLoading = false
            return
        }

        guard let token = UserDefaults.standard.string(forKey: tokenKey) else {
            errorMessage = "User not authenticated"
            isLoading = false
            return
        }

        var request = URLRequest(url: URL(string: "\(baseURL)/emotion/detect")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid server response"
                    return
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No data received from server"
                    return
                }

                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON Response: \(jsonString)")
                    }
                    
                    // Decode response
                    let response = try JSONDecoder().decode(EmotionResponse.self, from: data)
                    self?.detectedEmotion = response.emotion
                    self?.detectedUserId = response.userId

                } catch {
                    self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    print("Decoding Error: \(error)")
                }
            }
        }.resume()
    }
    func fetchEmotionStats(days: Int) async throws -> EmotionStats {
            guard let url = URL(string: "\(baseURL)/emotion/stats") else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Debug: Print the received JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(EmotionStats.self, from: data)
        }
}
