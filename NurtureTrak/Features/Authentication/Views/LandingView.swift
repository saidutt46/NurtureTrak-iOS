import SwiftUI

struct LandingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showLoginView = false
    @State private var showRegisterView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("NurtureTrak")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.black)
                
                Text("Tracking the First Steps with Care")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                
                Spacer()
                
                CustomButton(title: "Get Started for Free", action: {
                    showRegisterView = true
                }, backgroundColor: .softTeal)
                
                CustomButton(title: "Log In", action: {
                    showLoginView = true
                }, backgroundColor: .mutedNavyBlue)
            }
            .padding()
            .background(Color.paleGreen.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showLoginView) {
                LoginView()
                    .environmentObject(authManager) // Pass the environment object
            }
            .sheet(isPresented: $showRegisterView) {
                RegisterView()
            }
            .fullScreenCover(isPresented: $authManager.isAuthenticated) {
                MainTabView()
                    .environmentObject(authManager) // Pass the environment object
            }
        }
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
            .environmentObject(AuthenticationManager())
    }
}
