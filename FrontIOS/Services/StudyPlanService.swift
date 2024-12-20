import Foundation

class StudyPlanService {
    static let shared = StudyPlanService()
    private let baseURL = "http://172.18.25.95:3000"
    private let tokenKey = "authToken"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    private let authManager = AuthenticationManager.shared

    enum StudyPlanServiceError: Error {
        case userNotAuthenticated
        case invalidURL
    }

    func generateStudyPlan(userType: String, emotion: String, examDate: String) async throws -> StudyPlan {
        guard let token = UserDefaults.standard.string(forKey: tokenKey) else {
            errorMessage = "User not authenticated"
            print("Token not found in UserDefaults")
            throw StudyPlanServiceError.userNotAuthenticated
        }

        isLoading = true

        guard let url = URL(string: "\(baseURL)/study-plan") else {
            throw StudyPlanServiceError.invalidURL
        }

        let body: [String: Any] = [
            "userType": userType,
            "emotion": emotion,
            "examDate": examDate
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        isLoading = false
        return try JSONDecoder().decode(StudyPlan.self, from: data)
    }
}
