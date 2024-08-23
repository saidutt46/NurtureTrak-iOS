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
    @Published var passwordError = ""
    
    @Published var isEmailFieldTouched = false
    @Published var isEmailFieldEditing = false
    @Published var isPasswordFieldTouched = false
    @Published var isPasswordFieldEditing = false
    
    private let authManager: AuthenticationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthenticationManager = AuthenticationManager()) {
        self.authManager = authManager
        setupValidation()
    }
    
    private func setupValidation() {
        $email
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .filter { _ in self.isEmailFieldTouched && !self.isEmailFieldEditing }
            .map { self.validateEmail($0) }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellables)
        
        $password
            .map { self.validatePassword($0) }
            .filter { _ in self.isPasswordFieldTouched && !self.isPasswordFieldEditing }
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellables)
    }
    
    func emailEditingChanged(isEditing: Bool) {
        isEmailFieldEditing = isEditing
        if !isEditing {
            isEmailFieldTouched = true
        }
    }
    
    func passwordEditiinChanged(isEditing: Bool) {
        isPasswordFieldEditing = isEditing
        if !isEditing {
            isPasswordFieldTouched = true
        }
    }
    
    private func validateEmail(_ email: String) -> String {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email) ? "" : "Invalid email format"
    }
    
    private func validatePassword(_ password: String) -> String {
        return password.isEmpty ? "Password is required" : ""
    }
    
    var isValid: Bool {
        return emailError.isEmpty && passwordError.isEmpty && !email.isEmpty && !password.isEmpty
    }
    
    func validateAllFields() {
        emailError = validateEmail(email)
        passwordError = validatePassword(password)
    }
    
    @MainActor
    func login() async {
        validateAllFields()
        guard isValid else {
            if email.isEmpty && password.isEmpty {
                errorMessage = "Please enter your email and password."
            } else if email.isEmpty {
                errorMessage = "Please enter your email."
            } else if password.isEmpty {
                errorMessage = "Please enter your password."
            } else {
                errorMessage = "Please correct the errors in the form."
            }
            return
        }
        
        isLoading = true
        errorMessage = ""
        do {
            try await authManager.signIn(email: email, password: password)
            isLoginSuccessful = true
            authManager.isAuthenticated = true
        } catch {
            handleLoginError(error)
        }
        isLoading = false
    }
    
    private func handleLoginError(_ error: Error) {
        if let authError = error as? AuthError {
            switch authError {
            case .invalidCredentials:
                errorMessage = authError.errorDescription ?? "Invalid email or password"
            case .accountNotVerified:
                errorMessage = authError.errorDescription ?? "Account not verified"
            case .invalidToken:
                errorMessage = authError.errorDescription ?? "Invalid token"
            case .networkError(let message):
                errorMessage = "Network error: \(message)"
            case .serverError(let message):
                errorMessage = "Server error: \(message)"
            case .decodingError:
                errorMessage = authError.errorDescription ?? "Decoding error"
            case .noAccessToken:
                errorMessage = authError.errorDescription ?? "No access token"
            case .noRefreshToken:
                errorMessage = authError.errorDescription ?? "No refresh token"
            case .emailAlreadyInUse, .invalidEmail, .weakPassword, .registrationFailed:
                errorMessage = "An unexpected error occurred during login"
            }
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        print("Login error: \(error.localizedDescription)")
    }
    
    func signInWithGoogle() async {
        // Implement Google sign-in
        // You might want to add a method in AuthManager for this
    }
    
    func signInWithApple() async {
        // Implement Apple sign-in
        // You might want to add a method in AuthManager for this
    }
    
    @MainActor
    func forgotPassword() async {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        
        guard emailError.isEmpty else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        isLoading = true
        do {
            try await authManager.forgotPassword(email: email)
            errorMessage = "Password reset instructions sent to your email."
        } catch {
            errorMessage = "Failed to send password reset. Please try again."
        }
        isLoading = false
    }
}
