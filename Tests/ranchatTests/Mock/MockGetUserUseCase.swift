//
//  MockGetUserUseCase.swift
//  ranchatTests
//

@testable import ranchat

class MockGetUserUseCase: GetUserUseCase {
    var shouldThrow = false
    var mockUser = User(id: "test-user-id", name: "테스트유저")
    var callCount = 0

    func execute(userId: String) async throws -> User {
        callCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return mockUser
    }
}
