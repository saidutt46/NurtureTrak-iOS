//
//  MainTabView.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                ChildrenView()
                    .tabItem {
                        Label("Children", systemImage: "person.2")
                    }
                SessionsView()
                    .tabItem {
                        Label("Sessions", systemImage: "clock")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
            }
            .accentColor(.softTeal)  // Use your app's primary color

            // Add a shadow above the TabView
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color.white) // Background color of the shadow line
                    .frame(height: 0.5) // Thin rectangle to simulate the shadow line
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: -4)
                    .padding(/*@START_MENU_TOKEN@*/EdgeInsets()/*@END_MENU_TOKEN@*/)
                    .padding(.bottom, 100)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthenticationManager())
    }
}
