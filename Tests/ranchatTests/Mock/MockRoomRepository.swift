//
//  MockRoomRepository.swift
//  ranchatTests
//

@testable import ranchat

class MockRoomRepository: RoomRepository {
    var shouldThrow = false
    var mockRoomExist = false
    var mockRooms: [RoomData] = []
    var mockRoomId = "999"
    var getRoomsCallCount = 0
    var checkRoomExistCallCount = 0

    func getRooms(userId: String, page: Int, size: Int) async throws -> RoomDataList {
        getRoomsCallCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        let data = RoomDataListResponseData(
            items: mockRooms,
            page: page,
            size: size,
            totalCount: mockRooms.count,
            totalPage: 1,
            empty: mockRooms.isEmpty
        )
        return RoomDataList(status: "SUCCESS", message: "", serverDateTime: "", data: data)
    }

    func checkRoomExist(userId: String) async throws -> Bool {
        checkRoomExistCallCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return mockRoomExist
    }

    func getRoomDetail(userId: String, roomId: String) async throws -> RoomDetailData {
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return RoomDetailData(id: 1, title: "테스트방", type: "NORMAL", participants: [])
    }

    func createRoom(userId: String) async throws -> String {
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return mockRoomId
    }
}
