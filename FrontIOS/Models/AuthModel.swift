//
//  AuthModel.swift
//  FrontIOS
//
//  Created by Mac Mini 5 on 13/11/2024.
//

struct User: Codable {
    let name: String
    let email: String
    let password: String
    let id: String
    let version: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case password
        case id = "_id"
        case version = "__v"
    }

}

struct ForgotPasswordResponse: Codable {
    let message: String
    let userId: String
}


struct ResetPasswordResponse: Codable {
    var status: String
    var message: String
}


struct ErrorResponse: Codable {
    let message: String
    let error: String
    let statusCode: Int
}


struct SignInResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let userId: String
}
struct UserIdResponse: Decodable {
    let userId: String
}


struct UserDetails: Codable {
    let userId: String
    let name: String
    let email: String
}	
