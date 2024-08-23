import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel: RegisterViewModel
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
        ScrollView {
            VStack(spacing: 20) {
                Text("START NURTURING TODAY!")
                    .font(.headline)
                    .padding(.top)
                
                socialButtons
                
                Text("OR SIGN UP WITH EMAIL")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                inputFields
                
                passwordRequirements
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                registerButton
                
                alreadyHaveAccountSection
                
                termsAndPrivacySection
            }
            .padding()
        }
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
    
    private var socialButtons: some View {
        VStack(spacing: 10) {
            CustomButton(
                title: "Continue with Apple",
                backgroundColor: .white,
                foregroundColor: .black,
                borderColor: .gray,
                icon: Image(systemName: "apple.logo"),
                width: buttonWidth,
                height: buttonHeight
            ) {
                Task {
                    await viewModel.signUpWithApple()
                }
            }
            
            CustomButton(
                title: "Continue with Google",
                backgroundColor: .white,
                foregroundColor: .black,
                borderColor: .gray,
                icon: Image("google"),
                width: buttonWidth,
                height: buttonHeight
            ) {
                Task {
                    await viewModel.signUpWithGoogle()
                }
            }
        }
    }
    
    private var inputFields: some View {
        VStack(spacing: 15) {
            CustomTextField(placeholder: "Enter your first name", text: $viewModel.firstName, error: viewModel.firstNameError)
            CustomTextField(placeholder: "Enter your last name", text: $viewModel.lastName, error: viewModel.lastNameError)
            CustomTextField(placeholder: "Enter your email address", text: $viewModel.email, error: viewModel.emailError)
                .onChange(of: viewModel.email) { old, new in
                    viewModel.emailEditingChanged(isEditing: true)
                }
                .onSubmit {
                    viewModel.emailEditingChanged(isEditing: false)
                }
            CustomSecureField(placeholder: "Enter your password", text: $viewModel.password, error: "")
        }
    }
    
    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: 5) {
            PasswordRequirementRow(isValid: viewModel.isPasswordLengthValid, text: "At least 8 characters")
            PasswordRequirementRow(isValid: viewModel.isPasswordUppercaseValid, text: "At least one uppercase letter")
            PasswordRequirementRow(isValid: viewModel.isPasswordDigitValid, text: "At least one digit")
            PasswordRequirementRow(isValid: viewModel.isPasswordSpecialCharValid, text: "At least one special character (@$!%*?&)")
        }
    }
    
    private var registerButton: some View {
        CustomButton(
            title: "Sign Up",
            backgroundColor: .black,
            width: buttonWidth,
            height: buttonHeight
        ) {
            Task {
                await viewModel.register()
                if viewModel.isRegistrationSuccessful {
                    showingVerificationAlert = viewModel.verificationRequired
                    if !viewModel.verificationRequired {
                        await signInAfterRegistration()
                    }
                }
            }
        }
        .disabled(viewModel.isLoading)
    }
    
    private var alreadyHaveAccountSection: some View {
        HStack {
            Text("Already have an account?")
            Button("Sign in") {
                dismiss()
                showLoginView = true
            }
            .foregroundColor(.green)
        }
        .font(.footnote)
    }
    
    private var termsAndPrivacySection: some View {
        VStack(spacing: 10) {
            Text("By filling in the form above and tapping the \"Sign Up\" button, you accept and agree to Evite's Privacy Policy and Terms of Service")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Do Not Sell My Info") {
                // Handle do not sell info action
            }
            .font(.caption2)
            .foregroundColor(.blue)
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

struct PasswordRequirementRow: View {
    let isValid: Bool
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .green : .gray)
            Text(text)
                .font(.caption)
        }
    }
}
