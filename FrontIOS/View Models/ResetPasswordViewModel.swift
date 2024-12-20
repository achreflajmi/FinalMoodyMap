import Foundation

@MainActor
class ResetPasswordViewModel: ObservableObject {
    @Published var resetCode = ""
    @Published var newPassword = ""
    @Published var isError = false
    @Published var errorMessage = ""
    @Published var isPasswordReset = false
    @Published var userId = ""
    
    private var networkService = NetworkService()
    
    private func resetPassword() async {
        do {
            // Attempt to reset the password using network service
            try await networkService.resetPassword(userId: userId, newPassword: newPassword)
            
            // If no errors, indicate that password has been reset
            isPasswordReset = true
            isError = false
        } catch {
            // Handle different error cases
            isError = true
            if let networkError = error as? NetworkError {
                switch networkError {
                case .serverError(let message):
                    errorMessage = message
                default:
                    errorMessage = "An unexpected error occurred."
                }
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}
