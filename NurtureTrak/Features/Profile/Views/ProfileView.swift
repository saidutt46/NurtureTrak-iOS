//
//  ProfileView.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = ProfileViewModel()
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
                    await viewModel.forgotPassword()
                }
                CustomButton(title: "Logout",
                             backgroundColor: .vistaBlue,
                             width: buttonWidth,
                             height: buttonHeight) {
                    await authManager.signOut()
                }
                .padding(.bottom, 10)
            }
        }
        .alert(item: Binding<AlertItem?>(
            get: { self.authManager.errorMessage.map { AlertItem(message: $0) } },
            set: { _ in self.authManager.errorMessage = nil }
        )) { alertItem in
            Alert(title: Text("Error"), message: Text(alertItem.message))
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
