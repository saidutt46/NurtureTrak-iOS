//
//  HomeViewModel.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var userFirstName = ""
    @Published var userLastName = ""
    @Published var lastSessionDate: String = "Aug 10"
    @Published var lastSessionTime: String = "10:28"

    func fetchUserInfo() {
        // Assuming you stored the first name and last name in UserDefaults during login
        self.userFirstName = UserDefaults.standard.string(forKey: "userFirstName") ?? "John Tester"
        self.userLastName = UserDefaults.standard.string(forKey: "userLastName") ?? ""
    }
    
    func createSession() {
        // should implement
    }
    
    func startNewSessionFlow() {
        // TODO:: 
    }
  }
