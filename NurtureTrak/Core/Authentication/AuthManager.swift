//
//  AuthManager.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var verificationRequired: Bool = false
    @Published var user: User?
    private let networkManager: NetworkManager
    private let tokenManager: TokenManager
    
    init(networkManager: NetworkManager = NetworkManager(), tokenManager: TokenManager = TokenManager()) {
        self.networkManager = networkManager
        self.tokenManager = tokenManager
    }
    
    func signIn(email: String, password: String) async throws {
        let endpoint = APIEndpoint.login
        let body: [String: Any] = ["email": email, "password": password]
        
        let data = try await networkManager.sendRequest(to: endpoint, method: .post, body: body)
        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        await MainActor.run {
            self.user = response.user
            self.isAuthenticated = true
            // Store user information in UserDefaults
            UserDefaults.standard.set(response.user.firstName, forKey: "userFirstName")
            UserDefaults.standard.set(response.user.lastName, forKey: "userLastName")
            UserDefaults.standard.set(response.user.email, forKey: "userEmail")
        }
        
        tokenManager.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
    }
    
    func register(email: String, password: String, firstName: String, lastName: String) async throws {
        let endpoint = APIEndpoint.register
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName
        ]
        
        do {
            let data = try await networkManager.sendRequest(to: endpoint, method: .post, body: body)
            let response = try JSONDecoder().decode(RegisterResponse.self, from: data)
            
            await MainActor.run {
                self.verificationRequired = response.verificationRequired
            }
        } catch {
            throw error // Propagate the error
        }
    }
    
    func signOut() async throws {
        guard let accessToken = tokenManager.getAccessToken() else {
            throw AuthError.noAccessToken
        }
        
        let endpoint = APIEndpoint.logout
        _ = try await networkManager.sendRequest(to: endpoint, method: .post, headers: ["Authorization": "Bearer \(accessToken)"])
        
        await MainActor.run {
            self.isAuthenticated = false
            self.user = nil
        }
        
        tokenManager.clearTokens()
    }
    
    func refreshToken() async throws {
        guard let refreshToken = tokenManager.getRefreshToken() else {
            throw AuthError.noRefreshToken
        }
        
        let endpoint = APIEndpoint.refreshToken
        let body: [String: Any] = ["refreshToken": refreshToken]
        
        let data = try await networkManager.sendRequest(to: endpoint, method: .post, body: body)
        let response = try JSONDecoder().decode(RefreshTokenResponse.self, from: data)
        
        tokenManager.saveTokens(accessToken: response.accessToken, refreshToken: nil)
    }
    
    func forgotPassword(email: String) async throws {
        let endpoint = APIEndpoint.forgotPassword
        let body: [String: Any] = ["email": email]
        
        let data = try await networkManager.sendRequest(to: endpoint, method: .post, body: body)
        let response = try JSONDecoder().decode(MessageResponse.self, from: data)
        
        await MainActor.run {
            self.errorMessage = response.message // In this case, it's a success message
        }
    }
    
    func resetPassword(token: String, newPassword: String) async throws {
        let endpoint = APIEndpoint.resetPassword
        let body: [String: Any] = ["token": token, "newPassword": newPassword]
        
        let data = try await networkManager.sendRequest(to: endpoint, method: .post, body: body)
        let response = try JSONDecoder().decode(MessageResponse.self, from: data)
        
        await MainActor.run {
            self.errorMessage = response.message // In this case, it's a success message
        }
    }
}
