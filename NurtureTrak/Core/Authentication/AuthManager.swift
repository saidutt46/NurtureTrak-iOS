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
    let baseUrl: String = "http://192.168.1.80:3000/api/users/"
    
    func signIn(email: String, password: String) async throws {
        let url = URL(string: baseUrl + "login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let accessToken = json["accessToken"] as? String,
           let refreshToken = json["refreshToken"] as? String,
           let userData = json["user"] as? [String: Any],
           let userId = userData["id"] as? String,
           let userEmail = userData["email"] as? String,
           let firstName = userData["firstName"] as? String,
           let lastName = userData["lastName"] as? String {
            
            // Store tokens securely (consider using Keychain for better security)
            UserDefaults.standard.set(accessToken, forKey: "accessToken")
            UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
            
            // Create and store user object
            await MainActor.run {
                self.user = User(id: userId, email: userEmail, firstName: firstName, lastName: lastName)
                UserDefaults.standard.set(firstName, forKey: "userFirstName")
                UserDefaults.standard.set(lastName, forKey: "userLastName")
                UserDefaults.standard.set(email, forKey: "userEmail")
                
                self.isAuthenticated = true
            }
        } else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response format."])
        }
    }
    
    func register(email: String, password: String, firstName: String, lastName: String) async throws {
        let url = URL(string: baseUrl + "register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let success = json["success"] as? Bool, success {
                if let verificationRequired = json["verificationRequired"] as? Bool {
                    await MainActor.run {
                        self.verificationRequired = verificationRequired
                    }
                }
            } else {
                if let message = json["message"] as? String {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                } else if let errors = json["errors"] as? [String: String] {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errors.values.joined(separator: "\n")])
                } else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Registration failed."])
                }
            }
        } else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected server response."])
        }
    }
    
    func signOut() async {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            await MainActor.run {
                self.errorMessage = "No access token found."
                self.isAuthenticated = false
                self.user = nil
            }
            return
        }
        
        let url = URL(string: baseUrl + "logout")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                await MainActor.run {
                    // Clear stored tokens and user data
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                    UserDefaults.standard.removeObject(forKey: "userFirstName")
                    UserDefaults.standard.removeObject(forKey: "userLastName")
                    
                    self.isAuthenticated = false
                    self.user = nil
                }
            } else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Logout failed"])
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error during logout: \(error.localizedDescription)"
            }
        }
    }
    
    func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
            self.errorMessage = "No refresh token found."
            completion(false)
            return
        }
        
        let url = URL(string: baseUrl + "refresh-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["refreshToken": refreshToken]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            self.errorMessage = "Failed to create request body."
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received from the server."
                    completion(false)
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let newAccessToken = json["accessToken"] as? String {
                        UserDefaults.standard.set(newAccessToken, forKey: "accessToken")
                        completion(true)
                    } else {
                        self.errorMessage = "Invalid server response format."
                        completion(false)
                    }
                } catch {
                    self.errorMessage = "Failed to parse server response."
                    completion(false)
                }
            }
        }.resume()
    }
    
    func forgotPassword(email: String) async throws {
        let url = URL(string: baseUrl + "forgot-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = json["message"] as? String {
                await MainActor.run {
                    self.errorMessage = message // In this case, it's a success message
                }
            } else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response format."])
            }
        } catch {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse server response."])
        }
    }
    
    func resetPassword(token: String, newPassword: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: baseUrl + "reset-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "token": token,
            "newPassword": newPassword
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            self.errorMessage = "Failed to create request body."
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received from the server."
                    completion(false)
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = json["message"] as? String {
                        self.errorMessage = message // In this case, it's a success message
                        completion(true)
                    } else {
                        self.errorMessage = "Invalid server response format."
                        completion(false)
                    }
                } catch {
                    self.errorMessage = "Failed to parse server response."
                    completion(false)
                }
            }
        }.resume()
    }
}

struct User {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
}
