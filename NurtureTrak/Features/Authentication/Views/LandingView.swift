import SwiftUI

struct LandingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = LandingViewModel()
    @State private var showLoginView = false
    @State private var showRegisterView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing:10) {
                    Text("NurtureTrak")
                        .font(.system(size: 36, weight: .medium, design: .default))
                        .foregroundColor(.black)

                    Text("Tracking the First Steps with Care")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)

                    VStack(alignment: .leading, spacing: 8) {
                        HeroTextBullet(emoji: "👶", text: "Multiple child profiles")
                        HeroTextBullet(emoji: "🍼", text: "Feeding session tracking:")
                        HeroTextBullet(emoji: "   ", text: "- Breastfeeding", isIndented: true)
                        HeroTextBullet(emoji: "   ", text: "- Bottle feeding", isIndented: true)
                        HeroTextBullet(emoji: "   ", text: "- Pumping", isIndented: true)
                        HeroTextBullet(emoji: "⏱️", text: "Session duration tracking")
                        HeroTextBullet(emoji: "📊", text: "Basic feeding analytics")
                        HeroTextBullet(emoji: "🔔", text: "Feeding reminders")
                        HeroTextBullet(emoji: "🔒", text: "Secure data storage")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.white)
                
                VStack(spacing: 20) {
                    CustomButton(title: "Get Started for Free", action: {
                        showRegisterView = true
                    }, backgroundColor: .softTeal)

                    CustomButton(title: "Log In", action: {
                        showLoginView = true
                    }, backgroundColor: .mutedNavyBlue)
                }
                .padding(.bottom, 20)
                .background(Color.white)
            }
            .background(Color.hanBlue.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showLoginView) {
                LoginView(authManager: authManager, showRegisterView: $showRegisterView)
            }
            .sheet(isPresented: $showRegisterView) {
                RegisterView(showLoginView: $showLoginView)
                    .environmentObject(authManager)
            }
            .fullScreenCover(isPresented: $authManager.isAuthenticated) {
                MainTabView()
                    .environmentObject(authManager)
            }
        }
    }
}

struct HeroTextBullet: View {
    var emoji: String
    var text: String
    var isIndented: Bool = false

    var body: some View {
        HStack(alignment: .top) {
            Text(emoji)
                .font(.system(size: 18))
                .foregroundColor(.gray)
            
            Text(text)
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .padding(.leading, isIndented ? 20 : 0)
        }
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
            .environmentObject(AuthenticationManager())
    }
}
