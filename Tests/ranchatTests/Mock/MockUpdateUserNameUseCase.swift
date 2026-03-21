//
//  MockUpdateUserNameUseCase.swift
//  ranchatTests
//

@testable import ranchat

class MockUpdateUserNameUseCase: UpdateUserNameUseCase {
    var shouldThrow = false
    var callCount = 0
    var lastUpdatedName: String?

    func execute(userId: String, name: String) async throws {
        callCount += 1
        lastUpdatedName = name
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
    }
}
