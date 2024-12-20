import Foundation
import SwiftUI
import AuthenticationServices

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var needsAssessment: Bool = false
    
    static let shared = AuthenticationManager()
    private let tokenKey = "authToken"
    private let userKey = "currentUser"
    private let googleTokenKey = "googleIdToken"
    
    init() {
        // Check for existing auth token on launch
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            self.isAuthenticated = true
            loadCurrentUser()
        }
        checkAuthenticationStatus()
    }
    
    public func checkAuthenticationStatus() {
        // Check for any existing authentication token
        if let backendToken = UserDefaults.standard.string(forKey: tokenKey) {
            self.isAuthenticated = true
            loadCurrentUser()
        } else if let googleToken = UserDefaults.standard.string(forKey: googleTokenKey) {
            self.isAuthenticated = true
            loadGoogleUserInfo()
        }

        // Check assessment status if user is authenticated
        if let user = currentUser {
            checkIfNeedsAssessment(for: user.email)
        }
    }

    
    func signIn(with response: SignInResponse, user: User) {
        // Save the access token
        UserDefaults.standard.set(response.accessToken, forKey: tokenKey)
        
        // Save the user data
        saveCurrentUser(user)
        
        // Set authentication state
        self.isAuthenticated = true
        
        // Check if the user needs assessment
        checkIfNeedsAssessment(for: user.email)
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: googleTokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.removeObject(forKey: "googleUserInfo")
        self.isAuthenticated = false
        self.currentUser = nil
        self.needsAssessment = false
    }
    
    private func loadGoogleUserInfo() {
        if let userInfo = UserDefaults.standard.dictionary(forKey: "googleUserInfo") {
            print("Loaded Google user info: \(userInfo)")
        }
    }
    
    func getToken() async throws -> String? {
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            return token
        }
        return nil
    }
    
    private func loadCurrentUser() {
        if let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            checkIfNeedsAssessment(for: user.email)
        }
    }
    
    func saveCurrentUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
            self.currentUser = user
            checkIfNeedsAssessment(for: user.email)
        }
    }
    
    // MARK: - Mood Assessment Methods
    
    public func checkIfNeedsAssessment(for email: String) {
        let defaults = UserDefaults.standard
        let key = "assessment_completed_\(email)"
        
        // If assessment has not been completed, set needsAssessment to true
        needsAssessment = !defaults.bool(forKey: key)
    }

    func markAssessmentCompleted() {
        guard let email = currentUser?.email else { return }
        let defaults = UserDefaults.standard
        let key = "assessment_completed_\(email)"
        
        // Mark the assessment as completed in UserDefaults
        defaults.set(true, forKey: key)
        defaults.synchronize()
        
        // Update the needsAssessment flag to false
        needsAssessment = false
    }

    

    func saveAssessmentScore(_ score: Int, message: String) {
        guard let email = currentUser?.email else { return }
        let defaults = UserDefaults.standard
        defaults.set(score, forKey: "assessment_score_\(email)")
        defaults.set(message, forKey: "assessment_message_\(email)")
        defaults.synchronize()
    }
    
    func getAssessmentResults() -> (score: Int, message: String)? {
        guard let email = currentUser?.email else { return nil }
        let defaults = UserDefaults.standard
        let score = defaults.integer(forKey: "assessment_score_\(email)")
        guard let message = defaults.string(forKey: "assessment_message_\(email)") else { return nil }
        return (score, message)
    }
}
