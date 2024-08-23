import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
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
        VStack(spacing: 20) {
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
            
            CustomButton(
                title: "Continue with Apple",
                backgroundColor: .white,
                foregroundColor: .black,
                borderColor: .gray,
                icon: Image(systemName: "apple.logo"),
                width: buttonWidth,
                height: buttonHeight
            ) {
                await viewModel.signInWithApple()
                if viewModel.isLoginSuccessful {
                    dismiss()
                }
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
                await viewModel.signInWithGoogle()
                if viewModel.isLoginSuccessful {
                    dismiss()
                }
            }
            
            Text("OR SIGN IN WITH EMAIL")
                .font(.caption)
                .foregroundColor(.gray)
            
            VStack(spacing: 15) {
                CustomTextField(placeholder: "Enter your email address", text: $viewModel.email)
                CustomSecureField(placeholder: "Enter your password", text: $viewModel.password)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            CustomButton(title: "Sign In", 
                         backgroundColor: .black,
                         width: buttonWidth,
                         height: buttonHeight) {
                await viewModel.login()
                if viewModel.isLoginSuccessful {
                    dismiss()
                }
            }
            .disabled(!viewModel.isValid || viewModel.isLoading)
            
            CustomButton(title: "Forgot Password?",
                         backgroundColor: .clear,
                         width: buttonWidth,
                         height: buttonHeight) {
                await viewModel.forgotPassword()
            }
            .foregroundColor(.blue)
            
            Spacer()
            
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
        .padding()
        .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}
