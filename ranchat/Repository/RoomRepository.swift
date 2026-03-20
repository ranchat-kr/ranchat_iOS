//
//  RoomRepository.swift
//  ranchat
//

protocol RoomRepository {
    func getRooms(userId: String, page: Int, size: Int) async throws -> RoomDataList
    func checkRoomExist(userId: String) async throws -> Bool
    func getRoomDetail(userId: String, roomId: String) async throws -> RoomDetailData
    func createRoom(userId: String) async throws -> String
}
