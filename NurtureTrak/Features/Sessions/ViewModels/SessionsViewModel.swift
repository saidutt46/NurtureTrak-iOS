//
//  SessionsViewModel.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation

class SessionsViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchSessions() {
        isLoading = true
        APIService.shared.getSessions { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let sessions):
                    self?.sessions = sessions
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func addSession(childId: String, type: String, startTime: Date, endTime: Date, duration: Int, details: [String: Any], notes: String) {
        isLoading = true
        
        // Convert type string to SessionType
        guard let sessionType = SessionType(rawValue: type) else {
            self.errorMessage = "Invalid session type"
            isLoading = false
            return
        }
        
        // Create SessionDetails from details dictionary
        let sessionDetails = SessionDetails(
            breast: details["breast"] as? String != nil ? Breast(rawValue: details["breast"] as! String) : nil,
            amount: details["amount"] as? Int,
            feedType: details["feedType"] as? String != nil ? FeedType(rawValue: details["feedType"] as! String) : nil,
            amountPumped: details["amountPumped"] as? Int,
            pumpedBreast: details["pumpedBreast"] as? String != nil ? Breast(rawValue: details["pumpedBreast"] as! String) : nil
        )
        
        APIService.shared.createSession(childId: childId, type: sessionType, startTime: startTime, endTime: endTime, duration: duration, details: sessionDetails, notes: notes) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let session):
                    self?.sessions.append(session)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deleteSession(id: String) {
        isLoading = true
        APIService.shared.deleteSession(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.sessions.removeAll { $0.id == id }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Add other methods for updating and deleting sessions as needed
}
