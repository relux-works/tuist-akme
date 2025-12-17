import XCTest
import Auth

final class AuthTests: XCTestCase {
    func testLoginReturnsToken() async throws {
        let service = AuthServiceImpl()
        let token = try await service.login(username: "user", password: "pass")
        XCTAssertFalse(token.isEmpty)
    }
}

