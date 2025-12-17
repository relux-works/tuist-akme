import Foundation
import AuthInterface

public final class AuthServiceImpl: AuthService {
    public init() {}

    public func login(username: String, password: String) async throws -> String {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        return "token"
    }
}

