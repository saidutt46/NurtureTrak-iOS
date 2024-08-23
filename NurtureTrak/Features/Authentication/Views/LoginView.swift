import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @Binding var showRegisterView: Bool
    let buttonHeight: CGFloat = 50
    var buttonWidth: CGFloat {
        UIScreen.main.bounds.width - 40 // 20 points padding on each side
    }
    
    init(authManager: AuthenticationManager, showRegisterView: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(authManager: authManager))
        _showRegisterView = showRegisterView
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                
                socialButtons
                
                Text("OR SIGN IN WITH EMAIL")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                inputFields
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                signInButton
                
                forgotPasswordButton
                
                Spacer()
                
                registerSection
            }
            .padding()
        }
        .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("SIGN IN TO YOUR ACCOUNT")
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
            }
        }
        .padding(.top)
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
                    await viewModel.signInWithApple()
                    if viewModel.isLoginSuccessful {
                        dismiss()
                    }
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
                    await viewModel.signInWithGoogle()
                    if viewModel.isLoginSuccessful {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var inputFields: some View {
        VStack(spacing: 15) {
            CustomTextField(
                placeholder: "Enter your email address",
                text: $viewModel.email,
                error: viewModel.emailError
            )
            .onTapGesture {
                viewModel.isEmailFieldTouched = true
            }
            CustomSecureField(
                placeholder: "Enter your password",
                text: $viewModel.password
            )
        }
    }
    
    private var signInButton: some View {
        CustomButton(
            title: "Sign In",
            backgroundColor: .black,
            width: buttonWidth,
            height: buttonHeight
        ) {
            Task {
                await viewModel.login()
                if viewModel.isLoginSuccessful {
                    dismiss()
                }
            }
        }
        .disabled(!viewModel.isValid || viewModel.isLoading)
    }
    
    private var forgotPasswordButton: some View {
        CustomButton(
            title: "Forgot Password?",
            backgroundColor: .clear,
            width: buttonWidth,
            height: buttonHeight
        ) {
            Task {
                await viewModel.forgotPassword()
            }
        }
        .foregroundColor(.blue)
    }
    
    private var registerSection: some View {
        HStack {
            Text("Don't have an account?")
            Button("Register") {
                dismiss()
                showRegisterView = true
            }
            .foregroundColor(.blue)
        }
        .font(.footnote)
    }
}
