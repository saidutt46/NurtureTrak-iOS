import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case accountNotVerified
    case invalidToken
    case networkError(String)
    case serverError(String)
    case decodingError
    case noAccessToken
    case noRefreshToken
    // New error cases for registration
    case emailAlreadyInUse
    case invalidEmail
    case weakPassword
    case registrationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .accountNotVerified:
            return "Please verify your email address before logging in."
        case .invalidToken:
            return "Your session has expired. Please log in again."
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "There was an error processing the server response."
        case .noAccessToken:
            return "No access token found. Please log in again."
        case .noRefreshToken:
            return "No refresh token found. Please log in again."
        // New error descriptions for registration
        case .emailAlreadyInUse:
            return "This email is already in use. Please use a different email or try logging in."
        case .invalidEmail:
            return "The email address is invalid. Please enter a valid email."
        case .weakPassword:
            return "The password is too weak. Please use a stronger password."
        case .registrationFailed(let message):
            return "Registration failed: \(message)"
        }
    }
}
