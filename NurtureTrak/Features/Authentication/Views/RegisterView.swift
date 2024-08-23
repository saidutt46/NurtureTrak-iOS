import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var showingVerificationAlert = false
    @Binding var showLoginView: Bool
    let buttonHeight: CGFloat = 50
    var buttonWidth: CGFloat {
        UIScreen.main.bounds.width - 40 // 20 points padding on each side
    }

    
    init(authManager: AuthenticationManager, showLoginView: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: RegisterViewModel(authManager: authManager))
        _showLoginView = showLoginView
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("START NURTURING TODAY!")
                .font(.headline)
                .padding(.top)
            
            CustomButton(
                title: "Continue with Apple",
                backgroundColor: .white,
                foregroundColor: .black,
                borderColor: .gray,
                icon: Image(systemName: "apple.logo"),
                width: buttonWidth,
                height: buttonHeight
            ) {
                await viewModel.signUpWithApple()
            }

            CustomButton(
                title: "Continue with Google",
                backgroundColor: .white,
                foregroundColor: .black,
                borderColor: .gray,
                icon: Image(systemName: "g.circle"),
                width: buttonWidth,
                height: buttonHeight
            ) {
                await viewModel.signUpWithGoogle()
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
            
            CustomButton(title: "Sign Up", 
                         backgroundColor: .black, width: buttonWidth, height: buttonHeight) {
                await performRegistration()
            }
            .disabled(!viewModel.isValid || viewModel.isLoading)
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
    
    private func performRegistration() async {
        await viewModel.register()
        if viewModel.isRegistrationSuccessful {
            showingVerificationAlert = viewModel.verificationRequired
            if !viewModel.verificationRequired {
                await signInAfterRegistration()
            }
        }
    }
    
    private func signInAfterRegistration() async {
        do {
            try await authManager.signIn(email: viewModel.email, password: viewModel.password)
            dismiss()
        } catch {
            viewModel.errorMessage = "Registration successful, but sign-in failed. Please try logging in manually."
        }
    }
}
