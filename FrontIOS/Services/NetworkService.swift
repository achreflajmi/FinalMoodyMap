//
//  NetworkService.swift
//  FrontIOS

import Foundation
import UIKit

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case invalidResponse
    case unauthorized
    case emailAlreadyExists
    case unknownError
}


class NetworkService {
    private let baseURL = "http://172.18.25.95:3000"
 
    func login(email: String, password: String) async throws -> SignInResponse {
            guard let url = URL(string: "\(baseURL)/auth/login") else {
                throw NetworkError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let body = ["email": email, "password": password]
            request.httpBody = try? JSONEncoder().encode(body)
            
            print("Request Body: \(body)")  // Print request body for debugging
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log the raw response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200, 201: // Success codes
                do {
                    let signInResponse = try JSONDecoder().decode(SignInResponse.self, from: data)
                    print("Decoded SignInResponse: \(signInResponse)")
                    return signInResponse
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    throw NetworkError.decodingError
                }
            case 401:
                print("Unauthorized access.")
                throw NetworkError.unauthorized
            default:
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    print("Server error: \(errorResponse.message)")
                    throw NetworkError.serverError(errorResponse.message)
                } catch {
                    print("Failed to decode error response: \(error.localizedDescription)")
                    throw NetworkError.serverError("An unknown error occurred")
                }
            }
        }

    func signUp(name: String, email: String, password: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/auth/signup") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = ["name": name, "email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Log the raw response data for debugging purposes
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Data: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 201: // Success - SignUp was successful, decode the User
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                print("test", user)
                return user
            } catch {
                print("Decoding error: \(error)") // Log error for debugging
                throw NetworkError.decodingError
            }
            
        case 400: // Error - Email already in use or other bad request
            if let responseString = String(data: data, encoding: .utf8), responseString.contains("Email already in use") {
                throw NetworkError.emailAlreadyExists
            }
            
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw NetworkError.serverError(errorResponse.message)
            } catch {
                print("Failed to decode error response: \(error)") // Log error if error response is malformed
                throw NetworkError.serverError("An unknown error occurred")
            }
            
        default: // Handle any other unexpected status codes
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw NetworkError.serverError(errorResponse.message)
            }
        }
    }
    


    func getUserIdByEmail(email: String) async throws -> UserIdResponse {
           guard let url = URL(string: "\(baseURL)/auth/get-user-id?email=\(email)") else {
               throw NetworkError.invalidURL
           }
            
           var request = URLRequest(url: url)
           request.httpMethod = "GET" // Change the method to GET
           request.setValue("application/json", forHTTPHeaderField: "Accept")

           let (data, response) = try await URLSession.shared.data(for: request)

           guard let httpResponse = response as? HTTPURLResponse else {
               throw NetworkError.invalidResponse
           }

           switch httpResponse.statusCode {
           case 201: // Success
               do {
                   let userIdResponse = try JSONDecoder().decode(UserIdResponse.self, from: data)
                   print("Fetching userId: \(userIdResponse)")
                   return userIdResponse
               } catch {
                   throw NetworkError.decodingError
               }
           case 400: // Invalid email or no user found
               throw NetworkError.serverError("Email does not exist.")
           default:
               throw NetworkError.serverError("An unknown error occurred")
           }
       }
    func forgotPassword(email: String) async throws -> ForgotPasswordResponse {
        guard let url = URL(string: "\(baseURL)/auth/forgot-password") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = ["email": email]
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200, 201:
            return try JSONDecoder().decode(ForgotPasswordResponse.self, from: data)
        default:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.message)
            }
            throw NetworkError.serverError("An unknown error occurred")
        }
    }

    func verifyResetCode(userId: String, resetCode: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/verify-code/\(userId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["resetCode": resetCode]
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.message)
            }
            throw NetworkError.serverError("Failed to verify reset code")
        }
    }

    func resetPassword(userId: String, newPassword: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/reset-password/\(userId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["newPassword": newPassword]
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.message)
            }
            throw NetworkError.serverError("Failed to reset password")
        }
    }
    func googleSignIn(idToken: String) async throws -> SignInResponse {
        guard let url = URL(string: "\(baseURL)/auth/google-signin") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = ["idToken": idToken]
        request.httpBody = try JSONEncoder().encode(body)
        
        print("Google Sign-In Request Body: \(body)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Log the raw response data for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("Google Sign-In Response Data: \(responseString)")
        }
        
        return try handleAuthResponse(data: data, response: response)
    }
    
    private func handleAuthResponse(data: Data, response: URLResponse) throws -> SignInResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200, 201:
            do {
                let signInResponse = try JSONDecoder().decode(SignInResponse.self, from: data)
                print("Decoded SignInResponse: \(signInResponse)")
                return signInResponse
            } catch {
                print("Decoding error: \(error)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to read data")")
                throw NetworkError.decodingError
            }
        case 401:
            print("Unauthorized access.")
            throw NetworkError.unauthorized
        default:
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                print("Server error: \(errorResponse.message)")
                throw NetworkError.serverError(errorResponse.message)
            } catch {
                print("Failed to decode error response: \(error)")
                throw NetworkError.serverError("An unknown error occurred")
            }
        }
    }
    func getUserDetails() async throws -> (userId: String, name: String, email: String) {
        guard let url = URL(string: "\(baseURL)/auth/user-details") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Access the token from AuthenticationManager
        if let token = try await AuthenticationManager.shared.getToken() { // Use 'await' here
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NetworkError.unauthorized // If no token, throw unauthorized error
        }

        // Use 'await' here to await the result of the asynchronous network request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200: // Success
            do {
                let userDetails = try JSONDecoder().decode(UserDetails.self, from: data)
                return (userId: userDetails.userId, name: userDetails.name, email: userDetails.email)
            } catch {
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("An unknown error occurred")
        }
    }

    func updateUserProfile(name: String, email: String, image: UIImage?) async throws {
           guard let url = URL(string: "\(baseURL)/auth/edit-profile") else {
               throw NetworkError.invalidURL
           }

           var request = URLRequest(url: url)
           request.httpMethod = "PATCH"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Access the token from AuthenticationManager
        if let token = try await AuthenticationManager.shared.getToken() { // Use 'await' here
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NetworkError.unauthorized // If no token, throw unauthorized error
        }
           // Image to Base64 (if provided)
           var imageBase64: String? = nil
           if let image = image {
               imageBase64 = image.jpegData(compressionQuality: 0.8)?.base64EncodedString()
           }
           
           // Create body
           let body: [String: Any] = [
               "name": name,
               "email": email,
               "image": imageBase64 ?? ""
           ]
           
           request.httpBody = try? JSONSerialization.data(withJSONObject: body)
           
           let (data, response) = try await URLSession.shared.data(for: request)
           guard let httpResponse = response as? HTTPURLResponse else {
               throw NetworkError.invalidResponse
           }
           
           switch httpResponse.statusCode {
           case 200:
               print("Profile updated successfully.")
           default:
               do {
                   let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                   throw NetworkError.serverError(errorResponse.message)
               } catch {
                   throw NetworkError.serverError("An unknown error occurred.")
               }
           }
       }
}

