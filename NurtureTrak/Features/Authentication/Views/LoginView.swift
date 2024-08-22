import Foundation
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Log In")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                
                CustomTextField(placeholder: "Email", text: $viewModel.email)
                CustomSecureField(placeholder: "Password", text: $viewModel.password)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                CustomButton(title: "Log In", action: {
                    viewModel.login(email: viewModel.email, password: viewModel.password) { success in
                        if success {
                            dismiss()
                        }
                        // If login fails, the viewModel will update the errorMessage
                    }
                }, backgroundColor: .forestGreen)
                    .disabled(!viewModel.isValid || viewModel.isLoading)
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                Text("or")
                    .foregroundColor(.gray)
                
                CustomButton(title: "Sign in with Google", action: {
                    viewModel.signInWithGoogle { success in
                        if success {
                            dismiss()
                        }
                        // Handle Google sign-in completion
                    }
                }, backgroundColor: .blue)
                
                CustomButton(title: "Sign in with Apple", action: {
                    viewModel.signInWithApple { success in
                        if success {
                            dismiss()
                        }
                        // Handle Apple sign-in completion
                    }
                }, backgroundColor: .black)
                
                Button("Forgot Password?", action: {
                    viewModel.forgotPassword(email: viewModel.email) { success in
                        if success {
                            // Handle successful password reset request
                            viewModel.errorMessage = "Password reset instructions sent to your email."
                        } else {
                            // Handle failed password reset request
                            viewModel.errorMessage = "Failed to send password reset. Please try again."
                        }
                    }
                })
                    .foregroundColor(.blue)
            }
            .padding()
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
}
