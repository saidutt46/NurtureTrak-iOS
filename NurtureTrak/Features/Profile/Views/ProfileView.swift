//
//  ProfileView.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingAlert = false
    @State private var alertMessage = ""

    let buttonHeight: CGFloat = 50
    var buttonWidth: CGFloat {
        UIScreen.main.bounds.width - 40 // 20 points padding on each side
    }

    var body: some View {
        NavigationView {
            VStack {
                // ADDITIONAL CODE
                
                Spacer()
                CustomButton(title: "Forgot Password?",
                             backgroundColor: .rougePink,
                             width: buttonWidth,
                             height: buttonHeight) {
                    Task {
                        await viewModel.forgotPassword()
                        if !viewModel.errorMessage.isEmpty {
                            showingAlert = true
                            alertMessage = viewModel.errorMessage
                        }
                    }
                }
                CustomButton(title: "Logout",
                             backgroundColor: .vistaBlue,
                             width: buttonWidth,
                             height: buttonHeight) {
                    Task {
                        do {
                            try await authManager.signOut()
                        } catch {
                            showingAlert = true
                            alertMessage = error.localizedDescription
                        }
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage))
        }
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationManager())
    }
}
