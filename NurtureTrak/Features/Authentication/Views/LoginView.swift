import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @Binding var showRegisterView: Bool
    
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
            
            Button(action: {
                viewModel.signInWithApple { success in
                    if success {
                        dismiss()
                    }
                }
            }) {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Continue with Apple")
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
            
            Button(action: {
                viewModel.signInWithGoogle { success in
                    if success {
                        dismiss()
                    }
                }
            }) {
                HStack {
                    Image(systemName: "g.circle")
                    Text("Continue with Google")
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
            
            Button(action: {
                viewModel.login(email: viewModel.email, password: viewModel.password) { success in
                    if success {
                        dismiss()
                    }
                }
            }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!viewModel.isValid || viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            Button("Forgot Password?") {
                viewModel.forgotPassword(email: viewModel.email) { success in
                    if success {
                        viewModel.errorMessage = "Password reset instructions sent to your email."
                    } else {
                        viewModel.errorMessage = "Failed to send password reset. Please try again."
                    }
                }
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
