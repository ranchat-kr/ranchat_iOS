//
//  MockChatRepository.swift
//  ranchatTests
//

@testable import ranchat

class MockChatRepository: ChatRepository {
    var shouldThrow = false
    var mockMessages: [Message] = []
    var reportUserCallCount = 0

    func getMessages(roomId: String, page: Int, size: Int) async throws -> MessagePage {
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return MessagePage(items: mockMessages, totalCount: mockMessages.count)
    }

    func reportUser(roomId: String, reporterId: String, reportedUserId: String, reportType: String, reportReason: String) async throws {
        reportUserCallCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
    }
}
