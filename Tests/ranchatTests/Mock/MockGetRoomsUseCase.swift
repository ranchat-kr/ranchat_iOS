//
//  MockGetRoomsUseCase.swift
//  ranchatTests
//

@testable import ranchat

class MockGetRoomsUseCase: GetRoomsUseCase {
    var shouldThrow = false
    var mockRooms: [Room] = []
    var callCount = 0

    func execute(userId: String, page: Int, size: Int) async throws -> RoomPage {
        callCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return RoomPage(items: mockRooms, totalCount: mockRooms.count)
    }
}
