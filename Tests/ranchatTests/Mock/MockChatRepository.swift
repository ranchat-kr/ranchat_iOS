//
//  MockChatRepository.swift
//  ranchatTests
//

@testable import ranchat

class MockChatRepository: ChatRepository {
    var shouldThrow = false
    var mockMessages: [MessageData] = []
    var reportUserCallCount = 0

    func getMessages(roomId: String, page: Int, size: Int) async throws -> MessagesListResponseData {
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return MessagesListResponseData(
            items: mockMessages,
            page: page,
            size: size,
            totalCount: mockMessages.count,
            totalPage: 1,
            empty: mockMessages.isEmpty
        )
    }

    func reportUser(roomId: String, reporterId: String, reportedUserId: String, reportType: String, reportReason: String) async throws {
        reportUserCallCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
    }
}
