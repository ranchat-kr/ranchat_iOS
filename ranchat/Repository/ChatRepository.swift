//
//  ChatRepository.swift
//  ranchat
//

protocol ChatRepository {
    func getMessages(roomId: String, page: Int, size: Int) async throws -> MessagesListResponseData
    func reportUser(roomId: String, reporterId: String, reportedUserId: String, reportType: String, reportReason: String) async throws
}
