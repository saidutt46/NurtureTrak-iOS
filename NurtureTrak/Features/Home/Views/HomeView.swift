//
//  HomeView.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingAddChildSheet = false
    @State private var showingSelectChildSheet = false
    @State private var showingNewSessionSheet = false
    @StateObject private var childrenViewModel = ChildrenViewModel()
    @StateObject private var sessionsViewModel = SessionsViewModel()
    let buttonHeight: CGFloat = 50
    var buttonWidth: CGFloat {
        UIScreen.main.bounds.width - 40 // 20 points padding on each side
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top left alignment for "Hello" and the user's name
            VStack(alignment: .leading, spacing: 0) {
                Text("Hello")
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundColor(.black)
                    .padding(.top, 100)

                Text("\(viewModel.userFirstName) \(viewModel.userLastName)")
                    .font(.system(size: 24, weight: .regular, design: .default))
                    .foregroundColor(.black)
            }
            .padding(.leading, 20)

            Spacer().frame(height: 20)

            // Previous session timing with icon centered horizontally
            HStack {
                Label("Previous session", systemImage: "rectangle.stack")
                    .font(.system(size: 20, weight: .regular, design: .default))
                    .foregroundColor(.blue)

                Spacer()

                VStack(alignment: .trailing) {
                    Text(viewModel.lastSessionDate)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.gray)

                    Text(viewModel.lastSessionTime)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
            )
            .padding(.top, 20)
            
            // Display children
            ForEach(childrenViewModel.children) { child in
                Text(child.name)
            }
            
            // Display recent sessions
            ForEach(sessionsViewModel.sessions) { session in
                Text("Session for \(session.childId) at \(session.startTime)")
            }
            Spacer()
            
            // Start Feeding Session Button
            CustomButton(title: "Start Feeding Session",
                         backgroundColor: .blue,
                         width: buttonWidth,
                         height: buttonHeight,
                         action: viewModel.startNewSessionFlow)
                .padding(.bottom, 100)
        }
        .padding(20)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            viewModel.fetchUserInfo()
            childrenViewModel.fetchChildren()
            sessionsViewModel.fetchSessions()
        }
    }
}
