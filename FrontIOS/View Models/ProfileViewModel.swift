import Foundation
import Combine
import UIKit

class ProfileViewModel: ObservableObject {
    @Published var profileImage: UIImage? {
         didSet {
             saveProfileImage()
         }
     }  
    @Published var userName: String = "Loading..."
    @Published var userEmail: String = "Loading..."
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var showLogoutMessage: Bool = false
    @Published var navigateToLogin: Bool = false
    private let profileImageKey = "profileImageKey"

    private let networkService = NetworkService()
    init() {
           loadProfileImage()
       }

    func fetchUserDetails() async {
        await MainActor.run { self.isLoading = true }
        do {
            let (userId, name, email) = try await networkService.getUserDetails()
            await MainActor.run {
                self.userName = name
                self.userEmail = email
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load user details. Please try again."
            }
        }
    }

    // Update user profile
    func updateProfile(name: String, email: String, image: UIImage?) async {
        await MainActor.run { self.isLoading = true }
        do {
            try await networkService.updateUserProfile(name: name, email: email, image: image)
            await MainActor.run {
                self.userName = name
                self.userEmail = email
                self.errorMessage = nil
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to update profile. Please try again."
            }
        }
    }


    func saveProfileImage() {
        guard let image = profileImage else { return }
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            UserDefaults.standard.set(imageData, forKey: profileImageKey)
        }
    }

    func loadProfileImage() {
        if let imageData = UserDefaults.standard.data(forKey: profileImageKey),
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }
    // Handle user logout
    func logout(authManager: AuthenticationManager) async {
        await authManager.signOut()
        await MainActor.run {
            self.showLogoutMessage = true
            self.navigateToLogin = true
            profileImage = nil

        }
    }
    
}
