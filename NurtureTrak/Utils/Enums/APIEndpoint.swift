//
//  APIEndpoint.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/22/24.
//

import Foundation

enum APIEndpoint {
    case login
    case register
    case logout
    case refreshToken
    case forgotPassword
    case resetPassword
    
    var path: String {
        switch self {
        case .login:
            return "/users/login"
        case .register:
            return "/users/register"
        case .logout:
            return "/users/logout"
        case .refreshToken:
            return "/users/refresh-token"
        case .forgotPassword:
            return "/users/forgot-password"
        case .resetPassword:
            return "/users/reset-password"
        }
    }
}
