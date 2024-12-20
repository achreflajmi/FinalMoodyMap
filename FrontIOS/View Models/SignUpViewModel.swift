//
//  SignUpViewModel.swift
//  FrontIOS
//
//  Created by Mac Mini 5 on 13/11/2024.
//

import Foundation

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var agreeToTerms = false
    @Published var signUpMessage = ""
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var isSignUpSuccessful = false
    
    private let networkService = NetworkService()
    
    var isValidForm: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        let nameRegex = "[A-Za-z]"

        return !email.isEmpty &&
        emailPredicate.evaluate(with: email) &&
        !name.isEmpty &&
        !password.isEmpty &&
        password.count >= 6 &&
        agreeToTerms
    }
    
    func signUp() async {
        guard isValidForm else {
            signUpMessage = "Please check your inputs and agree to terms."
            showAlert = true
            return
        }
        
        isLoading = true
        signUpMessage = ""
        
        do {
            let user = try await networkService.signUp(
                name: name,
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            
          
            signUpMessage = "Sign-up successful!"
            isSignUpSuccessful = true
        } catch NetworkError.emailAlreadyExists {
            signUpMessage = "The email is already in use. Please choose a different one."
        } catch NetworkError.serverError(let message) {
            signUpMessage = message
        } catch {
            signUpMessage = "Sign-up failed: \(error.localizedDescription)"
        }
        
        isLoading = false
        showAlert = true
    }
}
