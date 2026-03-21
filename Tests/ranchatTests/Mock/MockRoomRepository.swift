//
//  MockRoomRepository.swift
//  ranchatTests
//

@testable import ranchat

class MockRoomRepository: RoomRepository {
    var shouldThrow = false
    var mockRoomExist = false
    var mockRooms: [Room] = []
    var mockRoomId = "999"
    var getRoomsCallCount = 0
    var checkRoomExistCallCount = 0

    func getRooms(userId: String, page: Int, size: Int) async throws -> RoomPage {
        getRoomsCallCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return RoomPage(items: mockRooms, totalCount: mockRooms.count)
    }

    func checkRoomExist(userId: String) async throws -> Bool {
        checkRoomExistCallCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return mockRoomExist
    }

    func getRoomDetail(userId: String, roomId: String) async throws -> RoomDetail {
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return RoomDetail(id: 1, title: "테스트방", type: .normal, participants: [])
    }

    func createRoom(userId: String) async throws -> String {
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return mockRoomId
    }
}
