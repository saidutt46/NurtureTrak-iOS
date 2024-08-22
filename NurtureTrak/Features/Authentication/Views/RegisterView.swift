import Foundation
import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State private var showingVerificationAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                
                CustomTextField(placeholder: "Email", text: $viewModel.email)
                CustomTextField(placeholder: "First Name", text: $viewModel.firstName)
                CustomTextField(placeholder: "Last Name", text: $viewModel.lastName)
                CustomSecureField(placeholder: "Password", text: $viewModel.password)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                CustomButton(title: "Register", action: {
                    viewModel.register(email: viewModel.email, password: viewModel.password) { success in
                        if success {
                            // Handle successful registration
                            if viewModel.verificationRequired {
                                showingVerificationAlert = true
                            } else {
                                signInAfterRegistration()
                            }
                        }
                        // If registration fails, the viewModel will update the errorMessage
                    }
                }, backgroundColor: .forestGreen)
                    .disabled(!viewModel.isValid)
                
                Text("or")
                    .foregroundColor(.gray)
                
                CustomButton(title: "Sign up with Google", action: viewModel.signUpWithGoogle, backgroundColor: .blue)
                CustomButton(title: "Sign up with Apple", action: viewModel.signUpWithApple, backgroundColor: .black)

                
                NavigationLink("Already have an account? Log in", destination: LoginView())
                    .foregroundColor(.blue)
            }
            .padding()
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onChange(of: viewModel.isRegistrationSuccessful) { _, success in
            if success {
                if viewModel.verificationRequired {
                    showingVerificationAlert = true
                } else {
                    signInAfterRegistration()
                }
            }
        }
        .alert(isPresented: $showingVerificationAlert) {
            Alert(
                title: Text("Verification Required"),
                message: Text("Please check your email to verify your account before logging in."),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                }
            )
        }
    }
    
    private func signInAfterRegistration() {
        authManager.signIn(email: viewModel.email, password: viewModel.password) { success in
            if success {
                dismiss()
            } else {
                // Handle sign-in failure
                viewModel.errorMessage = "Registration successful, but sign-in failed. Please try logging in manually."
            }
        }
    }
}
