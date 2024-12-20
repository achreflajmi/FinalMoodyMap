import Foundation
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var rememberMe = false
    @Published var signInMessage = ""
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var isSignInSuccessful = false
    
    private let networkService = NetworkService()
    private let authManager = AuthenticationManager.shared

    private func setMessage(_ message: String, isError: Bool = false) {
        signInMessage = message
        showAlert = isError
    }

    var isValidForm: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    func login() async {
        guard isValidForm else {
            setMessage("Please enter your email and password.", isError: true)
            return
        }
        
        isLoading = true
        setMessage("") // Clear previous messages
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        do {
            // Call the login API and get the response
            let response = try await networkService.login(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            
            // Assuming the response contains the userId or additional data
            // Create the User object using available data
            let user = User(
                name: "User Name", // Replace with actual user data
                email: email,      // The email from the form
                password: password, // Assuming you store the password (if necessary)
                id: response.userId,
                version: 1          // Assuming a default version or value
            )

            // Save the access token in UserDefaults
            UserDefaults.standard.set(response.accessToken, forKey: "authToken")
            
            // Sign the user in with both response and user object
            authManager.signIn(with: response, user: user)

            // Remember the email if required
            if rememberMe {
                UserDefaults.standard.set(email, forKey: "savedEmail")
            } else {
                UserDefaults.standard.removeObject(forKey: "savedEmail")
            }
            
            // Update the success state and message
            isSignInSuccessful = true
            setMessage("Sign-in successful!")
            
        } catch {
            // Handle errors by setting an appropriate message
            setMessage("Sign-in failed: \(error.localizedDescription)", isError: true)
        }
        
        isLoading = false
    }


    func loadSavedEmail() {
        if let savedEmail = UserDefaults.standard.string(forKey: "savedEmail") {
            email = savedEmail
            rememberMe = true
        }
    }
}
