//
//  MockGetMessagesUseCase.swift
//  ranchatTests
//

@testable import ranchat

class MockGetMessagesUseCase: GetMessagesUseCase {
    var shouldThrow = false
    var mockMessages: [Message] = []
    var callCount = 0

    func execute(roomId: String, page: Int, size: Int) async throws -> MessagePage {
        callCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return MessagePage(items: mockMessages, totalCount: mockMessages.count)
    }
}
