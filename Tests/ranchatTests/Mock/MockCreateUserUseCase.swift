//
//  MockCreateUserUseCase.swift
//  ranchatTests
//

@testable import ranchat

class MockCreateUserUseCase: CreateUserUseCase {
    var shouldThrow = false
    var callCount = 0

    func execute(id: String, name: String) async throws {
        callCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
    }
}
