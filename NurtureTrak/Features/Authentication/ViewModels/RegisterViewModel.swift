//
//  RegisterViewModel.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation

class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var password = ""
    @Published var isRegistrationSuccessful = false
    @Published var errorMessage: String?
    @Published var verificationRequired = false
    @Published var isLoading = false
    
    private let authManager: AuthenticationManager
    
    init(authManager: AuthenticationManager = AuthenticationManager()) {
        self.authManager = authManager
    }
    
    var isValid: Bool {
        !email.isEmpty && !firstName.isEmpty && !lastName.isEmpty && !password.isEmpty
    }
    
    func register() async {
        guard isValid else {
            self.errorMessage = "Please fill in all fields."
            return
        }
        
        await MainActor.run { self.isLoading = true }
        
        do {
            try await authManager.register(email: email, password: password, firstName: firstName, lastName: lastName)
            await MainActor.run {
                self.isRegistrationSuccessful = true
                self.verificationRequired = self.authManager.verificationRequired
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func signUpWithGoogle() async {
        // Implement Google sign-up
    }
    
    func signUpWithApple() async {
        // Implement Apple sign-up
    }
}
