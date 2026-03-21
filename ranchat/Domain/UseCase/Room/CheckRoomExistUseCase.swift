//
//  CheckRoomExistUseCase.swift
//  ranchat
//

import Foundation

protocol CheckRoomExistUseCase {
    func execute(userId: String) async throws -> Bool
}

final class DefaultCheckRoomExistUseCase: CheckRoomExistUseCase {
    private let roomRepository: RoomRepository

    init(roomRepository: RoomRepository = DefaultRoomRepository()) {
        self.roomRepository = roomRepository
    }

    func execute(userId: String) async throws -> Bool {
        try await roomRepository.checkRoomExist(userId: userId)
    }
}
