//
//  GetRoomsUseCase.swift
//  ranchat
//

import Foundation

protocol GetRoomsUseCase {
    func execute(userId: String, page: Int, size: Int) async throws -> RoomPage
}

final class DefaultGetRoomsUseCase: GetRoomsUseCase {
    private let roomRepository: RoomRepository

    init(roomRepository: RoomRepository = DefaultRoomRepository()) {
        self.roomRepository = roomRepository
    }

    func execute(userId: String, page: Int, size: Int) async throws -> RoomPage {
        try await roomRepository.getRooms(userId: userId, page: page, size: size)
    }
}
