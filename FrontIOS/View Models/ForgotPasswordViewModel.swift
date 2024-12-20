import Foundation

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isError = false
    @Published var errorMessage = ""
    @Published var isEmailSent = false
    
    private var networkService = NetworkService()
    
    func sendResetCode() async {
        do {
            try await networkService.forgotPassword(email: email)
            isEmailSent = true
            isError = false
        } catch {
            isError = true
            errorMessage = error.localizedDescription
        }
    }
}
