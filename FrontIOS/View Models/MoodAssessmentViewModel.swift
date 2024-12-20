import SwiftUI

@MainActor
class MoodAssessmentViewModel: ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswerIndex = -1
    @Published var totalScore = 0
    @Published var quizFinished = false
    @Published var shouldNavigateToHome = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var userType: String = ""
    
    private let baseURL = "http://172.18.25.95:3000"
    private let tokenKey = "authToken"
    let questions = MoodAssessmentData.questions
    let maxScore = MoodAssessmentData.maxScore
    private let authManager = AuthenticationManager.shared

    func handleAnswerSelected() {
        print("Selected index: \(selectedAnswerIndex), Calculated userType: \(getResultMessage())")
        if selectedAnswerIndex >= 0 {
            let score = questions[currentQuestionIndex].answers[selectedAnswerIndex].score
            totalScore += score
            print("Updated totalScore: \(totalScore)")
        }

        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerIndex = -1
            print("Next question: \(currentQuestionIndex)")
        } else {
            completeAssessment()
        }
    }

    private func completeAssessment() {
        guard let token = UserDefaults.standard.string(forKey: tokenKey) else {
            errorMessage = "User not authenticated"
            print("Token not found in UserDefaults")
            isLoading = false
            return
        }

        quizFinished = true
        isLoading = true
        print("Assessment is complete, submitting...")

        let resultMessage = getResultMessage()
        self.userType = resultMessage
        print("Result message: \(resultMessage)")

        Task { @MainActor in
            do {
                var request = URLRequest(url: URL(string: "\(baseURL)/auth/submit-assessment")!)
                request.httpMethod = "POST"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                // Ensure `userType` is included correctly
                let body: [String: String] = [
                    "userType": userType
                ]
                
                // Serialize the JSON correctly
                request.httpBody = try JSONEncoder().encode(body)

                print("Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")")

                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                print("HTTP Response: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    throw URLError(.cannotConnectToHost)
                }

                print("Assessment submission succeeded")
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self.shouldNavigateToHome = true
                print("Navigating to home screen...")

            } catch {
                self.errorMessage = "Error completing assessment: \(error.localizedDescription)"
                print("Error: \(error.localizedDescription)")
            }

            isLoading = false
        }
    }

    func getResultMessage() -> String {
        guard maxScore > 0 else {
            return "Invalid max score"
        }

        guard totalScore >= 0 else {
            return "Invalid total score"
        }

        let percentage = Double(totalScore) / Double(maxScore)

        if percentage >= 0.8 {
            return "Hard working"
        } else if percentage >= 0.6 {
            return "Normal pace"
        } else if percentage >= 0.4 {
            return "Lazy"
        } else {
            return "Unmotivated"
        }
    }
}
