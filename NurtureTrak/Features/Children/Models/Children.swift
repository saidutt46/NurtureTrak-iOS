//
//  Children.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation

struct Child: Codable, Identifiable {
    let id: String
    let name: String
    let dateOfBirth: Date
    let gender: String
    let parent: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, dateOfBirth, gender, parent, createdAt, updatedAt
    }
}
