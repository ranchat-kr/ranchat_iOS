//
//  ChatRepository.swift
//  ranchat
//

import Foundation

protocol ChatRepository {
    func getMessages(roomId: String, page: Int, size: Int) async throws -> MessagePage
    func reportUser(roomId: String, reporterId: String, reportedUserId: String, reportType: ReportType, reportReason: String) async throws
}
