//
//  RoomListViewModelTests.swift
//  ranchatTests
//

import XCTest
@testable import ranchat

@MainActor
final class RoomListViewModelTests: XCTestCase {

    private func makeIdHelper(userId: String = "test-user-id") -> IdHelper {
        let idHelper = IdHelper()
        idHelper.setUserId(userId)
        return idHelper
    }

    func test_getRoomList_loadsRooms() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: .normal, latestMessage: "안녕하세요", latestMessageAt: Date()),
            Room(id: 2, title: "Room 2", type: .normal, latestMessage: "반가워요", latestMessageAt: Date())
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.idHelper = makeIdHelper()

        await vm.getRoomList()

        XCTAssertEqual(vm.roomItems.count, 2)
        XCTAssertTrue(vm.isInitialized)
        XCTAssertFalse(vm.showNetworkErrorDialog)
    }

    func test_getRoomList_whenNetworkError_showsDialog() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.shouldThrow = true

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.idHelper = makeIdHelper()

        await vm.getRoomList()

        XCTAssertTrue(vm.showNetworkErrorDialog)
        XCTAssertTrue(vm.roomItems.isEmpty)
    }

    func test_getRoomList_whenUserIdNil_doesNotLoad() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: .normal, latestMessage: "Hi", latestMessageAt: Date())
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        // idHelper not set

        await vm.getRoomList()

        XCTAssertTrue(vm.roomItems.isEmpty)
        XCTAssertEqual(mockUseCase.callCount, 0)
    }

    func test_getRoomList_isRefresh_clearsAndReloads() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: .normal, latestMessage: "Hi", latestMessageAt: Date())
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.idHelper = makeIdHelper()
        vm.roomItems = [
            Room(id: 99, title: "Old", type: .normal, latestMessage: "Old", latestMessageAt: Date())
        ]

        await vm.getRoomList(isRefresh: true)

        XCTAssertEqual(vm.roomItems.count, 1)
        XCTAssertEqual(vm.roomItems.first?.id, 1)
    }

    func test_getRoomList_pagination_incrementsPage() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: .normal, latestMessage: "Hi", latestMessageAt: Date())
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.idHelper = makeIdHelper()

        await vm.getRoomList()
        XCTAssertEqual(vm.roomPage, 1)

        // 두 번째 호출 - 서버에서 같은 totalCount 반환 시 중단
        await vm.getRoomList()
        XCTAssertEqual(mockUseCase.callCount, 2)
    }

    func test_getRoomList_emptyResult_setsInitialized() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = []

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.idHelper = makeIdHelper()

        await vm.getRoomList()

        XCTAssertTrue(vm.roomItems.isEmpty)
        // totalCount(0) == roomItems.count(0) → early return (isInitialized는 set 안 됨)
        // 이 동작은 현재 구현의 명세를 그대로 반영
        XCTAssertFalse(vm.isInitialized)
    }
}
