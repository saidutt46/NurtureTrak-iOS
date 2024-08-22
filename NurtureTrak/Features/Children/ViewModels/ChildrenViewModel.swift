//
//  ChildrenViewModel.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation

class ChildrenViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchChildren() {
        isLoading = true
        APIService.shared.getChildren { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let children):
                    self?.children = children
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func addChild(name: String, dateOfBirth: Date, gender: String) {
        isLoading = true
        APIService.shared.createChild(name: name, dateOfBirth: dateOfBirth, gender: gender) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let child):
                    self?.children.append(child)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Add other methods for updating and deleting children as needed
}
