//
//  NetworkManager.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation

class NetworkManager {
    private let baseURL = "http://192.168.1.80:3000/api"
    
    func sendRequest(to endpoint: APIEndpoint, method: HTTPMethod, body: [String: Any]? = nil, headers: [String: String]? = nil) async throws -> Data {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError("Invalid response")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 401:
            throw AuthError.invalidCredentials
        case 403:
            throw AuthError.accountNotVerified
        default:
            throw AuthError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
