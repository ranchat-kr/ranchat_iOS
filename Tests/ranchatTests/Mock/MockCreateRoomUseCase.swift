//
//  MockCreateRoomUseCase.swift
//  ranchatTests
//

@testable import ranchat

class MockCreateRoomUseCase: CreateRoomUseCase {
    var shouldThrow = false
    var mockRoomId = "999"
    var callCount = 0

    func execute(userId: String) async throws -> String {
        callCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return mockRoomId
    }
}
