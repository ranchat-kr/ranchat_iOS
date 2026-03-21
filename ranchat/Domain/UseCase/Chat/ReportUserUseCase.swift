//
//  ReportUserUseCase.swift
//  ranchat
//

import Foundation

protocol ReportUserUseCase {
    func execute(roomId: String, reporterId: String, reportedUserId: String, reportType: String, reportReason: String) async throws
}

final class DefaultReportUserUseCase: ReportUserUseCase {
    private let chatRepository: ChatRepository

    init(chatRepository: ChatRepository = DefaultChatRepository()) {
        self.chatRepository = chatRepository
    }

    func execute(roomId: String, reporterId: String, reportedUserId: String, reportType: String, reportReason: String) async throws {
        try await chatRepository.reportUser(
            roomId: roomId,
            reporterId: reporterId,
            reportedUserId: reportedUserId,
            reportType: reportType,
            reportReason: reportReason
        )
    }
}
