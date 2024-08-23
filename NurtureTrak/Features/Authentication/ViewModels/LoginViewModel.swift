//
//  LoginViewModel.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoginSuccessful = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var emailError = ""
    @Published var isEmailFieldTouched = false
    
    private let authManager: AuthenticationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthenticationManager = AuthenticationManager()) {
        self.authManager = authManager
        setupValidation()
    }
    
    private func setupValidation() {
        $email
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .filter { _ in self.isEmailFieldTouched }
            .map { self.validateEmail($0) }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellables)
    }
    
    private func validateEmail(_ email: String) -> String {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email) ? "" : "Invalid email format"
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
                self.errorMessage = "" // Clear any previous error messages
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
