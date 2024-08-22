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
    
    private let authManager: AuthenticationManager
    
    init(authManager: AuthenticationManager = AuthenticationManager()) {
        self.authManager = authManager
    }
    
    var isValid: Bool {
        !email.isEmpty && !firstName.isEmpty && !lastName.isEmpty && !password.isEmpty
    }
    
    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard isValid else {
            self.errorMessage = "Please fill in all fields."
            return
        }
        
        authManager.register(email: email, password: password, firstName: firstName, lastName: lastName) { success in
            if success {
                self.isRegistrationSuccessful = true
                self.verificationRequired = self.authManager.verificationRequired
            } else {
                self.errorMessage = self.authManager.errorMessage
            }
            completion(success)
        }
    }
    
    func signUpWithGoogle() {
        // Implement Google sign-up
    }
    
    func signUpWithApple() {
        // Implement Apple sign-up
    }
}
