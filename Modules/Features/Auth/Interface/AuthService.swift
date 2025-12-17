import Foundation

public enum AuthError: Error, Equatable {
    case invalidCredentials
}

public protocol AuthService {
    func login(username: String, password: String) async throws -> String
}

