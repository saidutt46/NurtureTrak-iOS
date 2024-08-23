import SwiftUI

struct LandingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = LandingViewModel()
    @State private var showLoginView = false
    @State private var showRegisterView = false
    let buttonHeight: CGFloat = 50
    var buttonWidth: CGFloat {
        UIScreen.main.bounds.width - 40 // 20 points padding on each side
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(hex: "0093E9"), Color(hex: "80D0C7")]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("NurtureTrak")
                            .font(.system(size: 36, weight: .medium, design: .default))
                            .foregroundColor(.white)

                        Text("Tracking the First Steps with Care")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.8))

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
                    
                    VStack(spacing: 20) {
                        CustomButton(title: "Get Started for Free", backgroundColor: .white,
                                     foregroundColor: .softTeal,
                                     width: buttonWidth,
                                     height: buttonHeight,
                                     action: {
                                         showRegisterView = true
                                 })

                        CustomButton(title: "Log In", backgroundColor: .clear,
                                     foregroundColor: .white,
                                     width: buttonWidth,
                                     height: buttonHeight,
                                     action: {
                                         showLoginView = true
                                 })
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showLoginView) {
                LoginView(authManager: authManager, showRegisterView: $showRegisterView)
            }
            .sheet(isPresented: $showRegisterView) {
                RegisterView(authManager: authManager, showLoginView: $showLoginView)
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
                .foregroundColor(.white)
            
            Text(text)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.leading, isIndented ? 20 : 0)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
            .environmentObject(AuthenticationManager())
    }
}
