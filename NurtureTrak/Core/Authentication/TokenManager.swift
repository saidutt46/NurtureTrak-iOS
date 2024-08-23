//
//  TokenManager.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/22/24.
//

import Foundation

class TokenManager {
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    func saveTokens(accessToken: String, refreshToken: String?) {
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        if let refreshToken = refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
        }
    }
    
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }
    
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
}
