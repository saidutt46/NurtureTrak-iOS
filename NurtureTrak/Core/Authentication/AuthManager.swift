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
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "http://localhost:3000/api/users/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
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
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print(json)
                        if let accessToken = json["accessToken"] as? String,
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
                            self.user = User(id: userId, email: userEmail, firstName: firstName, lastName: lastName)
                            UserDefaults.standard.set(firstName, forKey: "userFirstName")
                            UserDefaults.standard.set(lastName, forKey: "userLastName")
                            
                            self.isAuthenticated = true
                            completion(true)
                        } else {
                            self.errorMessage = "Invalid server response format."
                            completion(false)
                        }
                    } else {
                        self.errorMessage = "Invalid JSON response from server."
                        completion(false)
                    }
                } catch {
                    self.errorMessage = "Failed to parse server response."
                    completion(false)
                }
            }
        }.resume()
    }
    
    func register(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "http://localhost:3000/api/users/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName
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
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool {
                            if success {
                                if let verificationRequired = json["verificationRequired"] as? Bool {
                                    self.verificationRequired = verificationRequired
                                }
                                completion(true)
                            } else {
                                if let message = json["message"] as? String {
                                    self.errorMessage = message
                                } else if let errors = json["errors"] as? [String: String] {
                                    self.errorMessage = errors.values.joined(separator: "\n")
                                } else {
                                    self.errorMessage = "Registration failed."
                                }
                                completion(false)
                            }
                        } else {
                            self.errorMessage = "Unexpected server response."
                            completion(false)
                        }
                    }
                } catch {
                    self.errorMessage = "Failed to parse server response."
                    completion(false)
                }
            }
        }.resume()
    }
    
    func signOut() {
        // Implement actual sign out logic here
        self.isAuthenticated = false
    }
}

struct User {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
}
