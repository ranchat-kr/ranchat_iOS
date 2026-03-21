//
//  RoomRepository.swift
//  ranchat
//

import Foundation

protocol RoomRepository {
    func getRooms(userId: String, page: Int, size: Int) async throws -> RoomPage
    func checkRoomExist(userId: String) async throws -> Bool
    func getRoomDetail(userId: String, roomId: String) async throws -> RoomDetail
    func createRoom(userId: String) async throws -> String
}
