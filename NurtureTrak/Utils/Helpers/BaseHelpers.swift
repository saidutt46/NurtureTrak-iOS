//
//  BaseHelpers.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/23/24.
//

import Foundation

// Define the ErrorResponse struct
struct ErrorResponse: Codable {
    let success: Bool
    let message: String
    let errors: [String: String]?
}
