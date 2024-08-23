//
//  ProfileViewModel.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation
class ProfileViewModel : ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    private let authManager: AuthenticationManager
    
    init(authManager: AuthenticationManager = AuthenticationManager()) {
        self.authManager = authManager
    }

    func forgotPassword() async {
        await MainActor.run { self.isLoading = true }
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        if !email.isEmpty {
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
}
