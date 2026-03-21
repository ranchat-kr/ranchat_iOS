//
//  CreateRoomUseCase.swift
//  ranchat
//

import Foundation

protocol CreateRoomUseCase {
    func execute(userId: String) async throws -> String
}

final class DefaultCreateRoomUseCase: CreateRoomUseCase {
    private let roomRepository: RoomRepository

    init(roomRepository: RoomRepository = DefaultRoomRepository()) {
        self.roomRepository = roomRepository
    }

    func execute(userId: String) async throws -> String {
        try await roomRepository.createRoom(userId: userId)
    }
}
