import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var showingVerificationAlert = false
    @Binding var showLoginView: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("START NURTURING TODAY!")
                .font(.headline)
                .padding(.top)
            
            Button(action: viewModel.signUpWithApple) {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Sign up with Apple")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            Button(action: viewModel.signUpWithGoogle) {
                HStack {
                    Image(systemName: "g.circle")
                    Text("Sign up with Google")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
            
            Text("OR SIGN UP WITH EMAIL")
                .font(.caption)
                .foregroundColor(.gray)
            
            VStack(spacing: 15) {
                CustomTextField(placeholder: "Enter your first name", text: $viewModel.firstName)
                CustomTextField(placeholder: "Enter your last name", text: $viewModel.lastName)
                CustomTextField(placeholder: "Enter your email address", text: $viewModel.email)
                CustomSecureField(placeholder: "Enter your password", text: $viewModel.password)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: {
                viewModel.register(email: viewModel.email, password: viewModel.password) { success in
                    if success {
                        showingVerificationAlert = true
                    }
                    // TODO::
//                    if success {
//                        if viewModel.verificationRequired {
//                            showingVerificationAlert = true
//                        } else {
//                            signInAfterRegistration()
//                        }
//                    }
                }
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!viewModel.isValid)
            
            HStack {
                Text("Already have an account?")
                Button("Sign in") {
                    // Navigate to sign in view
                    dismiss()
                    showLoginView = true
                }
                .foregroundColor(.green)
            }
            .font(.footnote)
            
            Text("By filling in the form above and tapping the \"Sign Up\" button, you accept and agree to Evite's Privacy Policy and Terms of Service")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Do Not Sell My Info") {
                // Handle do not sell info action
            }
            .font(.caption2)
            .foregroundColor(.blue)
        }
        .padding()
        .alert(isPresented: $showingVerificationAlert) {
            Alert(
                title: Text("Verification Required"),
                message: Text("Please check your email to verify your account before logging in."),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                    showLoginView = true

                }
            )
        }
    }
    
    private func signInAfterRegistration() {
        authManager.signIn(email: viewModel.email, password: viewModel.password) { success in
            if success {
                dismiss()
            } else {
                viewModel.errorMessage = "Registration successful, but sign-in failed. Please try logging in manually."
            }
        }
    }
}
