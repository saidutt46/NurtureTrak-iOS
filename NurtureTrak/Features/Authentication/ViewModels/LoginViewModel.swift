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
    
    func login() async {
        guard isValid else {
            self.errorMessage = "Please enter both email and password."
            return
        }
        
        await MainActor.run { self.isLoading = true }
        
        do {
            try await authManager.signIn(email: email, password: password)
            await MainActor.run {
                self.isLoginSuccessful = true
                self.authManager.isAuthenticated = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func signInWithGoogle() async {
        // Implement Google sign-in
        // You might want to add a method in AuthManager for this
    }
    
    func signInWithApple() async {
        // Implement Apple sign-in
        // You might want to add a method in AuthManager for this
    }
    
    func forgotPassword() async {
        guard !email.isEmpty else {
            self.errorMessage = "Please enter your email address."
            return
        }
        
        await MainActor.run { self.isLoading = true }
        
        do {
            try await authManager.forgotPassword(email: email)
            await MainActor.run {
                self.errorMessage = "Password reset instructions sent to your email."
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to send password reset. Please try again."
                self.isLoading = false
            }
        }
    }
}
