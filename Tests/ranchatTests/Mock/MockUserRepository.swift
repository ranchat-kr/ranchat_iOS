//
//  MockUserRepository.swift
//  ranchatTests
//

@testable import ranchat

class MockUserRepository: UserRepository {
    var shouldThrow = false
    var mockUser = UserData(id: "test-user-id", name: "테스트유저")
    var createUserCallCount = 0
    var updateUserNameCallCount = 0
    var lastUpdatedName: String?

    func createUser(id: String, name: String) async throws {
        createUserCallCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
    }

    func getUser(userId: String) async throws -> UserData {
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return mockUser
    }

    func updateUserName(userId: String, name: String) async throws {
        updateUserNameCallCount += 1
        lastUpdatedName = name
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
    }
}
