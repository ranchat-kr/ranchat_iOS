//
//  MockCheckRoomExistUseCase.swift
//  ranchatTests
//

@testable import ranchat

class MockCheckRoomExistUseCase: CheckRoomExistUseCase {
    var shouldThrow = false
    var mockRoomExist = false
    var callCount = 0

    func execute(userId: String) async throws -> Bool {
        callCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return mockRoomExist
    }
}
