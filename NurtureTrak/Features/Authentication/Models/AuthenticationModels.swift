//
//  AuthenticationModels.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/22/24.
//

import Foundation

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

struct RegisterResponse: Codable {
    let success: Bool
    let message: String
    let verificationRequired: Bool
}

struct RefreshTokenResponse: Codable {
    let accessToken: String
}

struct MessageResponse: Codable {
    let message: String
}

struct User: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
}
