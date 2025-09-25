import Foundation

enum TVServiceError: Error, LocalizedError {
    case connectionFailed(String)
    case commandFailed(String)
    case pinVerificationFailed(String)
    case deviceNotFound
    case invalidResponse
    case networkError(String)
    case authenticationFailed
    case timeout
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .commandFailed(let message):
            return "Command failed: \(message)"
        case .pinVerificationFailed(let message):
            return "PIN verification failed: \(message)"
        case .deviceNotFound:
            return "Device not found"
        case .invalidResponse:
            return "Invalid response"
        case .networkError(let message):
            return "Network error: \(message)"
        case .authenticationFailed:
            return "Authentication failed"
        case .timeout:
            return "Request timeout"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
