import Foundation
import AuthInterface

public final class MockAuthService: AuthService {
    public var tokenToReturn: String
    public var errorToThrow: Error?

    public init(tokenToReturn: String = "mock-token", errorToThrow: Error? = nil) {
        self.tokenToReturn = tokenToReturn
        self.errorToThrow = errorToThrow
    }

    public func login(username: String, password: String) async throws -> String {
        if let errorToThrow { throw errorToThrow }
        return tokenToReturn
    }
}

