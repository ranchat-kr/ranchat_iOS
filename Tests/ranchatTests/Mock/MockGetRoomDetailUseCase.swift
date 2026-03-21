//
//  MockGetRoomDetailUseCase.swift
//  ranchatTests
//

@testable import ranchat

class MockGetRoomDetailUseCase: GetRoomDetailUseCase {
    var shouldThrow = false
    var mockRoomDetail = RoomDetail(id: 1, title: "테스트방", type: .normal, participants: [])
    var callCount = 0

    func execute(userId: String, roomId: String) async throws -> RoomDetail {
        callCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        return mockRoomDetail
    }
}
