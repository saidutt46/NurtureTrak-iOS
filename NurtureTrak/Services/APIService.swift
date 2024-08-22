//
//  APIService.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:3000/api"
    
    private init() {}
    
    // MARK: - Children API calls
    
    func createChild(name: String, dateOfBirth: Date, gender: String, completion: @escaping (Result<Child, Error>) -> Void) {
        let endpoint = "\(baseURL)/children"
        let parameters: [String: Any] = [
            "name": name,
            "dateOfBirth": ISO8601DateFormatter().string(from: dateOfBirth),
            "gender": gender
        ]
        
        performRequest(endpoint: endpoint, method: "POST", parameters: parameters, completion: completion)
    }
    
    func getChildren(completion: @escaping (Result<[Child], Error>) -> Void) {
        let endpoint = "\(baseURL)/children"
        performRequest(endpoint: endpoint, method: "GET", completion: completion)
    }
    
    func getChild(id: String, completion: @escaping (Result<Child, Error>) -> Void) {
        let endpoint = "\(baseURL)/children/\(id)"
        performRequest(endpoint: endpoint, method: "GET", completion: completion)
    }
    
    func updateChild(id: String, name: String?, dateOfBirth: Date?, gender: String?, completion: @escaping (Result<Child, Error>) -> Void) {
        let endpoint = "\(baseURL)/children/\(id)"
        var parameters: [String: Any] = [:]
        if let name = name { parameters["name"] = name }
        if let dateOfBirth = dateOfBirth { parameters["dateOfBirth"] = ISO8601DateFormatter().string(from: dateOfBirth) }
        if let gender = gender { parameters["gender"] = gender }
        
        performRequest(endpoint: endpoint, method: "PUT", parameters: parameters, completion: completion)
    }
    
    func deleteChild(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = "\(baseURL)/children/\(id)"
        performRequestWithoutResponse(endpoint: endpoint, method: "DELETE", completion: completion)
    }
    
    // MARK: - Sessions API calls
    
    func createSession(childId: String, type: SessionType, startTime: Date, endTime: Date, duration: Int, details: SessionDetails, notes: String?, completion: @escaping (Result<Session, Error>) -> Void) {
        let endpoint = "\(baseURL)/sessions"
        var parameters: [String: Any] = [
            "childId": childId,
            "type": type.rawValue,
            "startTime": ISO8601DateFormatter().string(from: startTime),
            "endTime": ISO8601DateFormatter().string(from: endTime),
            "duration": duration
        ]
        
        var detailsDict: [String: Any] = [:]
        switch type {
        case .breastfeeding:
            if let breast = details.breast {
                detailsDict["breast"] = breast.rawValue
            }
        case .bottlefeeding:
            if let amount = details.amount {
                detailsDict["amount"] = amount
            }
            if let feedType = details.feedType {
                detailsDict["feedType"] = feedType.rawValue
            }
        case .pumping:
            if let amountPumped = details.amountPumped {
                detailsDict["amountPumped"] = amountPumped
            }
            if let pumpedBreast = details.pumpedBreast {
                detailsDict["pumpedBreast"] = pumpedBreast.rawValue
            }
        }
        
        parameters["details"] = detailsDict
        if let notes = notes {
            parameters["notes"] = notes
        }
        
        performRequest(endpoint: endpoint, method: "POST", parameters: parameters, completion: completion)
    }
    
    func getSessions(completion: @escaping (Result<[Session], Error>) -> Void) {
        let endpoint = "\(baseURL)/sessions"
        performRequest(endpoint: endpoint, method: "GET", completion: completion)
    }
    
    func getSession(id: String, completion: @escaping (Result<Session, Error>) -> Void) {
        let endpoint = "\(baseURL)/sessions/\(id)"
        performRequest(endpoint: endpoint, method: "GET", completion: completion)
    }
    
    func updateSession(id: String, childId: String?, type: String?, startTime: Date?, endTime: Date?, duration: Int?, details: [String: Any]?, notes: String?, completion: @escaping (Result<Session, Error>) -> Void) {
        let endpoint = "\(baseURL)/sessions/\(id)"
        var parameters: [String: Any] = [:]
        if let childId = childId { parameters["childId"] = childId }
        if let type = type { parameters["type"] = type }
        if let startTime = startTime { parameters["startTime"] = ISO8601DateFormatter().string(from: startTime) }
        if let endTime = endTime { parameters["endTime"] = ISO8601DateFormatter().string(from: endTime) }
        if let duration = duration { parameters["duration"] = duration }
        if let details = details { parameters["details"] = details }
        if let notes = notes { parameters["notes"] = notes }
        
        performRequest(endpoint: endpoint, method: "PUT", parameters: parameters, completion: completion)
    }
    
    func deleteSession(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = "\(baseURL)/sessions/\(id)"
        performRequestWithoutResponse(endpoint: endpoint, method: "DELETE", completion: completion)
    }
    
    // MARK: - Helper method for network requests
    
    private func performRequest<T: Decodable>(endpoint: String, method: String, parameters: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func performRequestWithoutResponse(endpoint: String, method: String, parameters: [String: Any]? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let url = URL(string: endpoint) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let parameters = parameters {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch {
                    completion(.failure(error))
                    return
                }
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
                }
            }.resume()
        }
}
