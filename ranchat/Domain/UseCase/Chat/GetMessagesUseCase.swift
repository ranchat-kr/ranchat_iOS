//
//  GetMessagesUseCase.swift
//  ranchat
//

import Foundation

protocol GetMessagesUseCase {
    func execute(roomId: String, page: Int, size: Int) async throws -> MessagePage
}

final class DefaultGetMessagesUseCase: GetMessagesUseCase {
    private let chatRepository: ChatRepository

    init(chatRepository: ChatRepository = DefaultChatRepository()) {
        self.chatRepository = chatRepository
    }

    func execute(roomId: String, page: Int, size: Int) async throws -> MessagePage {
        try await chatRepository.getMessages(roomId: roomId, page: page, size: size)
    }
}
