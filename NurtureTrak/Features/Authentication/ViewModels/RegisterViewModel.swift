//
//  RegisterViewModel.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//
import Foundation
import Combine

class RegisterViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    
    @Published var firstNameError = ""
    @Published var lastNameError = ""
    @Published var emailError = ""
    
    @Published var isPasswordLengthValid = false
    @Published var isPasswordUppercaseValid = false
    @Published var isPasswordDigitValid = false
    @Published var isPasswordSpecialCharValid = false
    
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isRegistrationSuccessful = false
    @Published var verificationRequired = false
    
    @Published var isEmailFieldTouched = false
    @Published var isEmailFieldEditing = false
    
    private var cancellables = Set<AnyCancellable>()
    private let authManager: AuthenticationManager
    
    init(authManager: AuthenticationManager) {
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
            .map { self.validatePasswordLength($0) }
            .assign(to: \.isPasswordLengthValid, on: self)
            .store(in: &cancellables)
        
        $password
            .map { self.validatePasswordUppercase($0) }
            .assign(to: \.isPasswordUppercaseValid, on: self)
            .store(in: &cancellables)
        
        $password
            .map { self.validatePasswordDigit($0) }
            .assign(to: \.isPasswordDigitValid, on: self)
            .store(in: &cancellables)
        
        $password
            .map { self.validatePasswordSpecialChar($0) }
            .assign(to: \.isPasswordSpecialCharValid, on: self)
            .store(in: &cancellables)
    }
    
    func emailEditingChanged(isEditing: Bool) {
        isEmailFieldEditing = isEditing
        if !isEditing {
            isEmailFieldTouched = true
        }
    }
    
    private func validateEmail(_ email: String) -> String {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email) ? "" : "Invalid email format"
    }
    
    private func validatePasswordLength(_ password: String) -> Bool {
        return password.count >= 8
    }
    
    private func validatePasswordUppercase(_ password: String) -> Bool {
        return password.contains(where: { $0.isUppercase })
    }
    
    private func validatePasswordDigit(_ password: String) -> Bool {
        return password.contains(where: { $0.isNumber })
    }
    
    private func validatePasswordSpecialChar(_ password: String) -> Bool {
        let specialCharRegex = "[@$!%*?&]"
        return password.range(of: specialCharRegex, options: .regularExpression) != nil
    }
    
    var isPasswordValid: Bool {
        return isPasswordLengthValid && isPasswordUppercaseValid && isPasswordDigitValid && isPasswordSpecialCharValid
    }
    
    var isValid: Bool {
        return !firstName.isEmpty && !lastName.isEmpty && emailError.isEmpty && isPasswordValid
    }
    
    func updatePasswordValidation() {
        isPasswordLengthValid = validatePasswordLength(password)
        isPasswordUppercaseValid = validatePasswordUppercase(password)
        isPasswordDigitValid = validatePasswordDigit(password)
        isPasswordSpecialCharValid = validatePasswordSpecialChar(password)
    }
    
    func validateAllFields() {
        firstNameError = firstName.isEmpty ? "First name is required" : ""
        lastNameError = lastName.isEmpty ? "Last name is required" : ""
        emailError = validateEmail(email)
    }
    
    @MainActor
    func register() async {
        validateAllFields()
        guard isValid else {
            errorMessage = "Please correct the errors in the form."
            return
        }
        
        isLoading = true
        errorMessage = ""
        do {
            try await authManager.register(email: email, password: password, firstName: firstName, lastName: lastName)
            isRegistrationSuccessful = true
            verificationRequired = true // Assuming verification is always required
        } catch {
            handleRegistrationError(error)
        }
        isLoading = false
    }
    
    private func handleRegistrationError(_ error: Error) {
        if let authError = error as? AuthError {
            switch authError {
            case .invalidCredentials:
                errorMessage = authError.errorDescription ?? "Invalid credentials"
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
            case .emailAlreadyInUse(let message):
                emailError = message
            case .invalidEmail:
                emailError = authError.errorDescription ?? "Invalid email"
            case .weakPassword:
                errorMessage = authError.errorDescription ?? "Weak password"
            case .registrationFailed(let message):
                errorMessage = "Registration failed: \(message)"
            }
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        print("Registration error: \(error.localizedDescription)")
    }
    
    func signUpWithApple() async {
        // Implement Apple sign up logic
    }
    
    func signUpWithGoogle() async {
        // Implement Google sign up logic
    }
}
