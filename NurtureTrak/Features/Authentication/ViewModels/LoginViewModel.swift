//
//  LoginViewModel.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoginSuccessful = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let authManager: AuthenticationManager
    
    init(authManager: AuthenticationManager = AuthenticationManager()) {
        self.authManager = authManager
    }
    
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard isValid else {
            self.errorMessage = "Please enter both email and password."
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        authManager.signIn(email: email, password: password) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return } // Safely unwrap self
                
                self.isLoading = false
                if success {
                    self.isLoginSuccessful = true
                    // You might want to move this logic to AuthManager if it's common for all login processes
                    if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
                        print("Access token stored: \(accessToken)")
                    }
                    // Consider moving user data storage to AuthManager as well
                    let firstName = UserDefaults.standard.string(forKey: "userFirstName") ?? ""
                    let lastName = UserDefaults.standard.string(forKey: "userLastName") ?? ""
                    print("Logged in user: \(firstName) \(lastName)")
                    self.authManager.isAuthenticated = true
                } else {
                    self.errorMessage = self.authManager.errorMessage
                }
                completion(success)
            }
        }
    }
    
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        // Implement Google sign-in
        // You might want to add a method in AuthManager for this
        completion(false)  // Placeholder, replace with actual implementation
    }
    
    func signInWithApple(completion: @escaping (Bool) -> Void) {
        // Implement Apple sign-in
        // You might want to add a method in AuthManager for this
        completion(false)  // Placeholder, replace with actual implementation
    }
    
    func forgotPassword(email: String, completion: @escaping (Bool) -> Void) {
        // Implement forgot password logic
        // You might want to add a method in AuthManager for this
        completion(false)  // Placeholder, replace with actual implementation
    }
}
