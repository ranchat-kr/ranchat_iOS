//
//  GetRoomDetailUseCase.swift
//  ranchat
//

import Foundation

protocol GetRoomDetailUseCase {
    func execute(userId: String, roomId: String) async throws -> RoomDetail
}

final class DefaultGetRoomDetailUseCase: GetRoomDetailUseCase {
    private let roomRepository: RoomRepository

    init(roomRepository: RoomRepository = DefaultRoomRepository()) {
        self.roomRepository = roomRepository
    }

    func execute(userId: String, roomId: String) async throws -> RoomDetail {
        try await roomRepository.getRoomDetail(userId: userId, roomId: roomId)
    }
}
